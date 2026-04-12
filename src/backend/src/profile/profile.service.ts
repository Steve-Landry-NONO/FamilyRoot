import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Profile } from '@prisma/client';

@Injectable()
export class ProfileService {
  constructor(private prisma: PrismaService) {}

  /**
   * Récupère un profil par ID avec ses relations
   */
  async findById(id: string): Promise<Profile> {
    const profile = await this.prisma.profile.findUnique({
      where: { id },
      include: {
        families: {
          include: {
            family: true,
          },
        },
        linkedMember: true,
      },
    });

    if (!profile) {
      throw new NotFoundException('Profile not found');
    }

    return profile;
  }

  /**
   * Met à jour un profil
   */
  async update(
    id: string,
    data: {
      firstName?: string;
      lastName?: string;
      avatarUrl?: string;
      fcmToken?: string;
    },
  ): Promise<Profile> {
    // Vérifier que le profil existe
    await this.findById(id);

    const updated = await this.prisma.profile.update({
      where: { id },
      data,
      include: {
        families: {
          include: {
            family: true,
          },
        },
        linkedMember: true,
      },
    });

    // Si le profil a un membre lié, synchroniser les noms
    if (updated.linkedMember && (data.firstName || data.lastName)) {
      await this.prisma.member.update({
        where: { id: updated.linkedMember.id },
        data: {
          ...(data.firstName && { firstName: data.firstName }),
          ...(data.lastName && { lastName: data.lastName }),
        },
      });
    }

    return updated;
  }

  /**
   * Met à jour le token FCM pour les push notifications
   */
  async updateFcmToken(id: string, fcmToken: string): Promise<Profile> {
    return this.prisma.profile.update({
      where: { id },
      data: { fcmToken },
    });
  }

  /**
   * Vérifie si un profil a une famille
   */
  async hasFamily(profileId: string): Promise<boolean> {
    const count = await this.prisma.userFamily.count({
      where: { profileId },
    });
    return count > 0;
  }
}
