import { ObjectType, Field, ID } from '@nestjs/graphql';

@ObjectType('Invitation')
export class InvitationType {
  @Field(() => ID)
  id: string;

  @Field({ description: 'Invitation code (INV-XXXXXXXXXXXX)' })
  code: string;

  @Field()
  expiresAt: Date;

  @Field({ nullable: true })
  usedAt?: Date;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  familyName?: string;

  @Field({ nullable: true })
  createdByName?: string;

  @Field({ description: 'Whether the invitation has been used' })
  isUsed: boolean;

  @Field({ description: 'Whether the invitation has expired' })
  isExpired: boolean;
}

@ObjectType('ValidateInvitationResult')
export class ValidateInvitationResult {
  @Field()
  valid: boolean;

  @Field({ nullable: true })
  familyName?: string;

  @Field({ nullable: true })
  error?: string;
}
