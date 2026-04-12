import { ObjectType, Field, ID, registerEnumType } from '@nestjs/graphql';

export enum NotificationTypeEnum {
  BIRTHDAY_REMINDER = 'BIRTHDAY_REMINDER',
  WEDDING_REMINDER = 'WEDDING_REMINDER',
  MEMBER_ADDED = 'MEMBER_ADDED',
  FAMILY_JOINED = 'FAMILY_JOINED',
  INVITATION_USED = 'INVITATION_USED',
}

registerEnumType(NotificationTypeEnum, {
  name: 'NotificationTypeEnum',
  description: 'Type of notification',
});

@ObjectType('Notification')
export class NotificationType {
  @Field(() => ID)
  id: string;

  @Field(() => NotificationTypeEnum)
  type: NotificationTypeEnum;

  @Field()
  title: string;

  @Field()
  body: string;

  @Field()
  isRead: boolean;

  @Field()
  createdAt: Date;
}
