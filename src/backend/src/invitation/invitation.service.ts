import {
  Injectable,
  NotFoundException,
  ConflictException,
  GoneException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Invitation, FamilyRole } from '@prisma/client';

@Injectable()
export class InvitationService {
  constructor(private prisma: PrismaService) {}

  /**
   * Génère un code d'invitation unique (INV-XXXXXXXXXXXX)
   */
  private generateInvitationCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 12; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return `INV-${code}`;
  }

  /**
   * Crée une nouvelle invitation
   */
  async createInvitation(
    profileId: string,
    familyId: string,
    expiresInDays: number = 7,
  ): Promise<Invitation> {
    // Vérifier que l'utilisateur est membre de la famille
    const membership = await this.prisma.userFamily.findUnique({
      where: {
        profileId_familyId: {
          profileId,
          familyId,
        },
      },
    });

    if (!membership) {
      throw new BadRequestException('You are not a member of this family');
    }

    // Générer un code unique
    let code = this.generateInvitationCode();
    let attempts = 0;
    while (await this.prisma.invitation.findUnique({ where: { code } })) {
      code = this.generateInvitationCode();
      attempts++;
      if (attempts > 10) {
        throw new Error('Failed to generate unique invitation code');
      }
    }

    // Calculer la date d'expiration
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + expiresInDays);

    return this.prisma.invitation.create({
      data: {
        familyId,
        code,
        createdById: profileId,
        expiresAt,
      },
      include: {
        family: true,
        createdBy: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });
  }

  /**
   * Valide un code d'invitation sans l'utiliser
   */
  async validateCode(code: string): Promise<{
    valid: boolean;
    familyName?: string;
    error?: string;
  }> {
    const invitation = await this.prisma.invitation.findUnique({
      where: { code },
      include: {
        family: true,
      },
    });

    if (!invitation) {
      return { valid: false, error: 'INVITATION_NOT_FOUND' };
    }

    if (invitation.usedAt) {
      return { valid: false, error: 'INVITATION_ALREADY_USED' };
    }

    if (new Date() > invitation.expiresAt) {
      return { valid: false, error: 'INVITATION_EXPIRED' };
    }

    return {
      valid: true,
      familyName: invitation.family.name,
    };
  }

  /**
   * Utilise un code d'invitation pour rejoindre une famille
   */
  async useInvitation(
    code: string,
    profileId: string,
    firstName: string,
    lastName: string,
  ): Promise<any> {
    // Valider le code
    const invitation = await this.prisma.invitation.findUnique({
      where: { code },
      include: {
        family: true,
      },
    });

    if (!invitation) {
      throw new NotFoundException('INVITATION_NOT_FOUND');
    }

    if (invitation.usedAt) {
      throw new ConflictException('INVITATION_ALREADY_USED');
    }

    if (new Date() > invitation.expiresAt) {
      throw new GoneException('INVITATION_EXPIRED');
    }

    // Vérifier que l'utilisateur n'est pas déjà dans une famille (MVP: 1 famille)
    const existingMembership = await this.prisma.userFamily.findFirst({
      where: { profileId },
    });

    if (existingMembership) {
      throw new ConflictException('ALREADY_IN_FAMILY');
    }

    // Transaction : marquer invitation used + créer membership + créer member "Moi"
    const result = await this.prisma.$transaction(async (tx) => {
      // 1. Marquer l'invitation comme utilisée
      await tx.invitation.update({
        where: { id: invitation.id },
        data: {
          usedById: profileId,
          usedAt: new Date(),
        },
      });

      // 2. Créer le membership
      await tx.userFamily.create({
        data: {
          profileId,
          familyId: invitation.familyId,
          role: FamilyRole.MEMBER,
        },
      });

      // 3. Créer le membre "Moi" lié au profil
      await tx.member.create({
        data: {
          familyId: invitation.familyId,
          linkedProfileId: profileId,
          firstName,
          lastName,
        },
      });

      // 4. Créer une notification pour l'admin
      const admins = await tx.userFamily.findMany({
        where: {
          familyId: invitation.familyId,
          role: FamilyRole.ADMIN,
        },
        select: { profileId: true },
      });

      for (const admin of admins) {
        await tx.notification.create({
          data: {
            profileId: admin.profileId,
            type: 'FAMILY_JOINED',
            title: 'Nouveau membre',
            body: `${firstName} ${lastName} a rejoint la famille`,
            data: { memberId: profileId },
          },
        });
      }

      return invitation.family;
    });

    return result;
  }

  /**
   * Récupère les invitations d'une famille
   */
  async getFamilyInvitations(familyId: string): Promise<Invitation[]> {
    return this.prisma.invitation.findMany({
      where: { familyId },
      include: {
        createdBy: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
        usedBy: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
}
