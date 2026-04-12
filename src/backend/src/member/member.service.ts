import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Member, RelationType } from '@prisma/client';

@Injectable()
export class MemberService {
  constructor(private prisma: PrismaService) {}

  /**
   * Récupère un membre par ID
   */
  async findById(id: string): Promise<Member> {
    const member = await this.prisma.member.findUnique({
      where: { id },
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
            toMember: true,
          },
        },
        relationsTo: {
          include: {
            fromMember: true,
          },
        },
        events: true,
      },
    });

    if (!member) {
      throw new NotFoundException('Member not found');
    }

    return member;
  }

  /**
   * Récupère tous les membres d'une famille
   */
  async findByFamily(familyId: string): Promise<Member[]> {
    return this.prisma.member.findMany({
      where: { familyId },
      include: {
        linkedProfile: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatarUrl: true,
          },
        },
        relationsFrom: true,
        relationsTo: true,
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  /**
   * Ajoute un nouveau membre à la famille
   * Crée automatiquement la relation inverse
   */
  async addMember(
    familyId: string,
    data: {
      firstName: string;
      lastName: string;
      relatedMemberId: string;
      relationType: RelationType;
      birthDate?: Date;
      deathDate?: Date;
      gender?: 'MALE' | 'FEMALE' | 'OTHER';
      birthPlace?: string;
      bio?: string;
    },
  ): Promise<Member> {
    // Vérifier que le membre lié existe et appartient à la même famille
    const relatedMember = await this.prisma.member.findUnique({
      where: { id: data.relatedMemberId },
    });

    if (!relatedMember || relatedMember.familyId !== familyId) {
      throw new BadRequestException('Related member not found in this family');
    }

    // Validation des dates
    if (data.birthDate && data.deathDate && data.birthDate >= data.deathDate) {
      throw new BadRequestException('Birth date must be before death date');
    }

    // Transaction : créer membre + relations bidirectionnelles
    const member = await this.prisma.$transaction(async (tx) => {
      // 1. Créer le membre
      const newMember = await tx.member.create({
        data: {
          familyId,
          firstName: data.firstName,
          lastName: data.lastName,
          birthDate: data.birthDate,
          deathDate: data.deathDate,
          gender: data.gender,
          birthPlace: data.birthPlace,
          bio: data.bio,
        },
      });

      // 2. Créer la relation FROM new member TO related member
      await tx.relationship.create({
        data: {
          fromMemberId: newMember.id,
          toMemberId: data.relatedMemberId,
          type: data.relationType,
        },
      });

      // 3. Créer la relation inverse
      const inverseType = this.getInverseRelationType(data.relationType);
      await tx.relationship.create({
        data: {
          fromMemberId: data.relatedMemberId,
          toMemberId: newMember.id,
          type: inverseType,
        },
      });

      // 4. Si birthDate fournie, créer un événement BIRTHDAY
      if (data.birthDate) {
        await tx.event.create({
          data: {
            familyId,
            memberId: newMember.id,
            type: 'BIRTHDAY',
            title: `Anniversaire de ${data.firstName}`,
            date: data.birthDate,
            isRecurring: true,
            reminderDays: [7, 1, 0],
          },
        });
      }

      return newMember;
    });

    return this.findById(member.id);
  }

  /**
   * Met à jour un membre
   */
  async updateMember(
    memberId: string,
    familyId: string,
    data: {
      firstName?: string;
      lastName?: string;
      birthDate?: Date;
      deathDate?: Date;
      gender?: 'MALE' | 'FEMALE' | 'OTHER';
      birthPlace?: string;
      bio?: string;
      photoUrl?: string;
    },
  ): Promise<Member> {
    // Vérifier que le membre existe et appartient à la famille
    const member = await this.prisma.member.findUnique({
      where: { id: memberId },
    });

    if (!member || member.familyId !== familyId) {
      throw new NotFoundException('Member not found in this family');
    }

    // Validation des dates
    const newBirthDate = data.birthDate ?? member.birthDate;
    const newDeathDate = data.deathDate ?? member.deathDate;
    if (newBirthDate && newDeathDate && newBirthDate >= newDeathDate) {
      throw new BadRequestException('Birth date must be before death date');
    }

    const updated = await this.prisma.member.update({
      where: { id: memberId },
      data,
    });

    // Si le membre a un profil lié, synchroniser les noms
    if (member.linkedProfileId && (data.firstName || data.lastName)) {
      await this.prisma.profile.update({
        where: { id: member.linkedProfileId },
        data: {
          ...(data.firstName && { firstName: data.firstName }),
          ...(data.lastName && { lastName: data.lastName }),
        },
      });
    }

    return this.findById(updated.id);
  }

  /**
   * Récupère les relations d'un membre
   */
  async getMemberRelations(memberId: string) {
    const relations = await this.prisma.relationship.findMany({
      where: {
        OR: [{ fromMemberId: memberId }, { toMemberId: memberId }],
      },
      include: {
        fromMember: true,
        toMember: true,
      },
    });

    return relations;
  }

  /**
   * Calcule les siblings (frères/sœurs) d'un membre
   * Basé sur les parents communs
   */
  async getSiblings(memberId: string): Promise<Member[]> {
    // Trouver les parents du membre
    const parentRelations = await this.prisma.relationship.findMany({
      where: {
        fromMemberId: memberId,
        type: 'CHILD', // Le membre est CHILD de ses parents
      },
      select: { toMemberId: true },
    });

    const parentIds = parentRelations.map((r) => r.toMemberId);

    if (parentIds.length === 0) {
      return [];
    }

    // Trouver tous les enfants de ces parents
    const siblingRelations = await this.prisma.relationship.findMany({
      where: {
        toMemberId: { in: parentIds },
        type: 'CHILD',
        fromMemberId: { not: memberId }, // Exclure le membre lui-même
      },
      select: { fromMemberId: true },
    });

    const siblingIds = [...new Set(siblingRelations.map((r) => r.fromMemberId))];

    if (siblingIds.length === 0) {
      return [];
    }

    return this.prisma.member.findMany({
      where: { id: { in: siblingIds } },
    });
  }

  /**
   * Retourne le type de relation inverse
   */
  private getInverseRelationType(type: RelationType): RelationType {
    switch (type) {
      case 'PARENT':
        return 'CHILD';
      case 'CHILD':
        return 'PARENT';
      case 'SPOUSE':
        return 'SPOUSE';
      default:
        return type;
    }
  }
}
