import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Notification, NotificationType } from '@prisma/client';

@Injectable()
export class NotificationService {
  constructor(private prisma: PrismaService) {}

  /**
   * Récupère les notifications d'un utilisateur
   */
  async getNotifications(
    profileId: string,
    options: {
      limit?: number;
      unreadOnly?: boolean;
    } = {},
  ): Promise<Notification[]> {
    const { limit = 50, unreadOnly = false } = options;

    return this.prisma.notification.findMany({
      where: {
        profileId,
        ...(unreadOnly && { isRead: false }),
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  /**
   * Compte les notifications non lues
   */
  async getUnreadCount(profileId: string): Promise<number> {
    return this.prisma.notification.count({
      where: {
        profileId,
        isRead: false,
      },
    });
  }

  /**
   * Marque une notification comme lue
   */
  async markAsRead(notificationId: string, profileId: string): Promise<Notification> {
    // Vérifier que la notification appartient à l'utilisateur
    const notification = await this.prisma.notification.findFirst({
      where: {
        id: notificationId,
        profileId,
      },
    });

    if (!notification) {
      throw new Error('Notification not found');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
  }

  /**
   * Marque toutes les notifications comme lues
   */
  async markAllAsRead(profileId: string): Promise<number> {
    const result = await this.prisma.notification.updateMany({
      where: {
        profileId,
        isRead: false,
      },
      data: { isRead: true },
    });

    return result.count;
  }

  /**
   * Crée une notification
   */
  async create(data: {
    profileId: string;
    type: NotificationType;
    title: string;
    body: string;
    data?: any;
  }): Promise<Notification> {
    return this.prisma.notification.create({
      data: {
        profileId: data.profileId,
        type: data.type,
        title: data.title,
        body: data.body,
        data: data.data || {},
      },
    });
  }

  /**
   * Crée des notifications pour tous les membres d'une famille
   */
  async notifyFamily(
    familyId: string,
    type: NotificationType,
    title: string,
    body: string,
    data?: any,
    excludeProfileId?: string,
  ): Promise<void> {
    const members = await this.prisma.userFamily.findMany({
      where: { familyId },
      select: { profileId: true },
    });

    const notifications = members
      .filter((m) => m.profileId !== excludeProfileId)
      .map((m) => ({
        profileId: m.profileId,
        type,
        title,
        body,
        data: data || {},
      }));

    await this.prisma.notification.createMany({
      data: notifications,
    });
  }

  /**
   * Supprime les anciennes notifications (plus de 30 jours)
   */
  async cleanOldNotifications(): Promise<number> {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const result = await this.prisma.notification.deleteMany({
      where: {
        createdAt: { lt: thirtyDaysAgo },
        isRead: true,
      },
    });

    return result.count;
  }
}
