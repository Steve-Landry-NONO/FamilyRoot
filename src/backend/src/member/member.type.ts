import { ObjectType, Field, ID, registerEnumType } from '@nestjs/graphql';

export enum Gender {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  OTHER = 'OTHER',
}

export enum RelationType {
  PARENT = 'PARENT',
  CHILD = 'CHILD',
  SPOUSE = 'SPOUSE',
}

registerEnumType(Gender, {
  name: 'Gender',
  description: 'Gender of a family member',
});

registerEnumType(RelationType, {
  name: 'RelationType',
  description: 'Type of relationship between members',
});

@ObjectType('Member')
export class MemberType {
  @Field(() => ID)
  id: string;

  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field({ nullable: true })
  birthDate?: Date;

  @Field({ nullable: true })
  deathDate?: Date;

  @Field(() => Gender, { nullable: true })
  gender?: Gender;

  @Field({ nullable: true })
  birthPlace?: string;

  @Field({ nullable: true })
  bio?: string;

  @Field({ nullable: true })
  photoUrl?: string;

  @Field()
  createdAt: Date;

  @Field()
  updatedAt: Date;

  @Field({ nullable: true, description: 'Whether this member has a linked user account' })
  hasLinkedProfile?: boolean;

  @Field({ nullable: true, description: 'Whether this member is deceased' })
  isDeceased?: boolean;

  @Field(() => [RelationshipType], { nullable: true })
  relations?: RelationshipType[];
}

@ObjectType('Relationship')
export class RelationshipType {
  @Field(() => ID)
  id: string;

  @Field(() => RelationType)
  type: RelationType;

  @Field(() => MemberType)
  fromMember: MemberType;

  @Field(() => MemberType)
  toMember: MemberType;

  @Field()
  createdAt: Date;
}
