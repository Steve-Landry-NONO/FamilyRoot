import { Injectable, ConflictException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Family, FamilyRole, FamilyTier, Profile } from '@prisma/client';
import { nanoid } from 'nanoid';

// Limites par tier
const TIER_LIMITS: Record<FamilyTier, number> = {
  FREE: 15,
  FAMILLE: 100,
  FAMILLE_PLUS: Infinity,
};

@Injectable()
export class FamilyService {
  constructor(private prisma: PrismaService) {}

  /**
   * Génère un code famille unique (FAM-XXXXXX)
   */
  private generateFamilyCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return `FAM-${code}`;
  }

  /**
   * Crée une nouvelle famille
   * - Vérifie que l'utilisateur n'a pas déjà une famille (MVP)
   * - Crée la famille avec code FAM-XXXXXX
   * - Ajoute le créateur comme ADMIN
   * - Crée un Member "Moi" lié au profil
   */
  async createFamily(
    profile: Profile,
    name: string,
    founderFirstName: string,
    founderLastName: string,
  ): Promise<Family> {
    // Vérifier que l'utilisateur n'a pas déjà une famille (contrainte MVP)
    const existingFamily = await this.prisma.userFamily.findFirst({
      where: { profileId: profile.id },
    });

    if (existingFamily) {
      throw new ConflictException('ALREADY_IN_FAMILY');
    }

    // Générer un code unique
    let code = this.generateFamilyCode();
    let attempts = 0;
    while (await this.prisma.family.findUnique({ where: { code } })) {
      code = this.generateFamilyCode();
      attempts++;
      if (attempts > 10) {
        throw new Error('Failed to generate unique family code');
      }
    }

    // Transaction : créer famille + userFamily + member "Moi"
    const family = await this.prisma.$transaction(async (tx) => {
      // 1. Créer la famille
      const newFamily = await tx.family.create({
        data: {
          name,
          code,
          tier: FamilyTier.FREE,
        },
      });

      // 2. Ajouter le créateur comme ADMIN
      await tx.userFamily.create({
        data: {
          profileId: profile.id,
          familyId: newFamily.id,
          role: FamilyRole.ADMIN,
        },
      });

      // 3. Créer le membre "Moi" lié au profil
      await tx.member.create({
        data: {
          familyId: newFamily.id,
          linkedProfileId: profile.id,
          firstName: founderFirstName,
          lastName: founderLastName,
        },
      });

      return newFamily;
    });

    return this.findById(family.id);
  }

  /**
   * Récupère une famille par ID avec ses membres
   */
  async findById(id: string): Promise<Family & { members: any[]; _count: { members: number } }> {
    const family = await this.prisma.family.findUnique({
      where: { id },
      include: {
        members: {
          include: {
            linkedProfile: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                avatarUrl: true,
              },
            },
            relationsFrom: {
              include: {
                fromMember: true,
                toMember: true,
              },
            },
            relationsTo: {
              include: {
                fromMember: true,
                toMember: true,
              },
            },
          },
        },
        _count: {
          select: { members: true },
        },
      },
    });

    if (!family) {
      throw new NotFoundException('Family not found');
    }

    return family;
  }

  /**
   * Récupère une famille par son code (FAM-XXXXXX)
   */
  async findByCode(code: string): Promise<Family | null> {
    return this.prisma.family.findUnique({
      where: { code },
    });
  }

  /**
   * Vérifie si un utilisateur est membre d'une famille
   */
  async isMember(profileId: string, familyId: string): Promise<boolean> {
    const membership = await this.prisma.userFamily.findUnique({
      where: {
        profileId_familyId: {
          profileId,
          familyId,
        },
      },
    });
    return !!membership;
  }

  /**
   * Vérifie si un utilisateur est admin d'une famille
   */
  async isAdmin(profileId: string, familyId: string): Promise<boolean> {
    const membership = await this.prisma.userFamily.findUnique({
      where: {
        profileId_familyId: {
          profileId,
          familyId,
        },
      },
    });
    return membership?.role === FamilyRole.ADMIN;
  }

  /**
   * Récupère la famille de l'utilisateur (MVP : une seule)
   */
  async getUserFamily(profileId: string): Promise<Family | null> {
    const userFamily = await this.prisma.userFamily.findFirst({
      where: { profileId },
      include: {
        family: {
          include: {
            members: {
              include: {
                linkedProfile: {
                  select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    avatarUrl: true,
                  },
                },
                relationsFrom: {
                  include: {
                    fromMember: true,
                    toMember: true,
                  },
                },
                relationsTo: {
                  include: {
                    fromMember: true,
                    toMember: true,
                  },
                },
              },
            },
            _count: {
              select: { members: true },
            },
          },
        },
      },
    });

    return userFamily?.family || null;
  }

  /**
   * Vérifie si on peut ajouter un membre (limite du tier)
   */
  async canAddMember(familyId: string): Promise<boolean> {
    const family = await this.prisma.family.findUnique({
      where: { id: familyId },
      include: {
        _count: {
          select: { members: true },
        },
      },
    });

    if (!family) {
      return false;
    }

    const limit = TIER_LIMITS[family.tier];
    return family._count.members < limit;
  }

  /**
   * Récupère les statistiques du dashboard
   */
  async getDashboardStats(familyId: string) {
    const [memberCount, upcomingEvents, recentMembers] = await Promise.all([
      // Nombre de membres
      this.prisma.member.count({ where: { familyId } }),
      
      // Événements à venir (7 prochains jours)
      this.prisma.event.findMany({
        where: {
          familyId,
          date: {
            gte: new Date(),
            lte: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
          },
        },
        orderBy: { date: 'asc' },
        take: 5,
        include: {
          member: {
            select: {
              firstName: true,
              lastName: true,
            },
          },
        },
      }),
      
      // Membres récemment ajoutés
      this.prisma.member.findMany({
        where: { familyId },
          take: 5,
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photoUrl: true,
          createdAt: true,
        },
      }),
    ]);

    // Calculer le nombre de générations
    const members = await this.prisma.member.findMany({
      where: { familyId },
      include: {
        relationsFrom: true,
        relationsTo: true,
      },
    });

    const generations = this.calculateGenerations(members);

    return {
      memberCount,
      generationCount: generations,
      upcomingEvents,
      recentMembers,
    };
  }

  /**
   * Calcule le nombre de générations dans l'arbre
   */
  private calculateGenerations(members: any[]): number {
    if (members.length === 0) return 0;

    // Construire le graphe
    const childToParents = new Map<string, string[]>();
    
    for (const member of members) {
      const parents = member.relationsTo
        .filter((r: any) => r.type === 'PARENT')
        .map((r: any) => r.fromMemberId);
      childToParents.set(member.id, parents);
    }

    // Trouver les racines (membres sans parents)
    const roots = members.filter((m) => {
      const parents = childToParents.get(m.id) || [];
      return parents.length === 0;
    });

    if (roots.length === 0) return 1;

    // BFS pour calculer la profondeur max
    let maxDepth = 0;
    const visited = new Set<string>();
    const queue: { id: string; depth: number }[] = roots.map((r) => ({ id: r.id, depth: 0 }));

    while (queue.length > 0) {
      const { id, depth } = queue.shift()!;
      
      if (visited.has(id)) continue;
      visited.add(id);
      
      maxDepth = Math.max(maxDepth, depth);

      // Trouver les enfants
      const children = members.filter((m) => {
        const parents = childToParents.get(m.id) || [];
        return parents.includes(id);
      });

      for (const child of children) {
        if (!visited.has(child.id)) {
          queue.push({ id: child.id, depth: depth + 1 });
        }
      }
    }

    return maxDepth + 1; // +1 car on commence à 0
  }
}
