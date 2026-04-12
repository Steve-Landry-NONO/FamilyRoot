import { Resolver, Query, Mutation, Args, Int } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { NotificationType } from './notification.type';

@Resolver(() => NotificationType)
export class NotificationResolver {
  constructor(private notificationService: NotificationService) {}

  /**
   * Query: notifications
   * Récupère les notifications de l'utilisateur
   */
  @Query(() => [NotificationType], { name: 'notifications' })
  @UseGuards(JwtAuthGuard)
  async notifications(
    @CurrentUser() user: any,
    @Args('limit', { type: () => Int, nullable: true, defaultValue: 50 }) limit: number,
    @Args('unreadOnly', { nullable: true, defaultValue: false }) unreadOnly: boolean,
  ): Promise<any[]> {
    return this.notificationService.getNotifications(user.id, { limit, unreadOnly });
  }

  /**
   * Query: unreadNotificationCount
   * Compte les notifications non lues
   */
  @Query(() => Int, { name: 'unreadNotificationCount' })
  @UseGuards(JwtAuthGuard)
  async unreadNotificationCount(@CurrentUser() user: any): Promise<number> {
    return this.notificationService.getUnreadCount(user.id);
  }

  /**
   * Mutation: markNotificationAsRead
   * Marque une notification comme lue
   */
  @Mutation(() => NotificationType)
  @UseGuards(JwtAuthGuard)
  async markNotificationAsRead(
    @CurrentUser() user: any,
    @Args('id') id: string,
  ): Promise<any> {
    return this.notificationService.markAsRead(id, user.id);
  }

  /**
   * Mutation: markAllNotificationsAsRead
   * Marque toutes les notifications comme lues
   */
  @Mutation(() => Int)
  @UseGuards(JwtAuthGuard)
  async markAllNotificationsAsRead(@CurrentUser() user: any): Promise<number> {
    return this.notificationService.markAllAsRead(user.id);
  }
}
