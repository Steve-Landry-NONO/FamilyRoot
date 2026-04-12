import { ObjectType, Field, ID, Int, registerEnumType } from '@nestjs/graphql';
import { MemberType } from '../member/member.type';

// Enregistrer les enums GraphQL
export enum FamilyTier {
  FREE = 'FREE',
  FAMILLE = 'FAMILLE',
  FAMILLE_PLUS = 'FAMILLE_PLUS',
}

registerEnumType(FamilyTier, {
  name: 'FamilyTier',
  description: 'Subscription tier for a family',
});

@ObjectType('Family')
export class FamilyType {
  @Field(() => ID)
  id: string;

  @Field()
  name: string;

  @Field({ description: 'Public family code (FAM-XXXXXX)' })
  code: string;

  @Field(() => FamilyTier)
  tier: FamilyTier;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  @Field(() => [MemberType], { nullable: true })
  members?: MemberType[];

  @Field(() => Int, { nullable: true })
  memberCount?: number;
}

@ObjectType('UpcomingEvent')
export class UpcomingEventType {
  @Field(() => ID)
  id: string;

  @Field()
  type: string;

  @Field()
  title: string;

  @Field()
  date: Date;

  @Field({ nullable: true })
  memberName?: string;
}

@ObjectType('RecentMember')
export class RecentMemberType {
  @Field(() => ID)
  id: string;

  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field({ nullable: true })
  photoUrl?: string;

  @Field()
  createdAt: Date;
}

@ObjectType('Dashboard')
export class DashboardType {
  @Field(() => FamilyType)
  family: FamilyType;

  @Field(() => Int)
  memberCount: number;

  @Field(() => Int)
  generationCount: number;

  @Field(() => [UpcomingEventType])
  upcomingEvents: UpcomingEventType[];

  @Field(() => [RecentMemberType])
  recentMembers: RecentMemberType[];
}
