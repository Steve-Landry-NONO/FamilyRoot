import { ObjectType, Field, ID } from '@nestjs/graphql';
import { FamilyType } from '../family/family.type';

@ObjectType('Profile')
export class ProfileType {
  @Field(() => ID)
  id: string;

  @Field()
  email: string;

  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field({ nullable: true })
  avatarUrl?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  // Relations (chargées dynamiquement via DataLoader ou include)
  @Field(() => [UserFamilyType], { nullable: true })
  families?: UserFamilyType[];

  @Field({ description: 'Whether the user has a family' })
  hasFamily?: boolean;
}

@ObjectType('UserFamily')
export class UserFamilyType {
  @Field(() => ID)
  id: string;

  @Field()
  role: string;

  @Field()
  joinedAt: Date;

  @Field(() => FamilyType)
  family: FamilyType;
}
