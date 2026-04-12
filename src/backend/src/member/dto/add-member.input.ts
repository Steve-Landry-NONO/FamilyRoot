import { InputType, Field } from '@nestjs/graphql';
import { IsString, MinLength, MaxLength, IsOptional, IsEnum, IsDate } from 'class-validator';
import { Type } from 'class-transformer';

@InputType()
export class AddMemberInput {
  @Field()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  firstName: string;

  @Field()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  lastName: string;

  @Field({ description: 'ID of an existing member to create a relationship with' })
  @IsString()
  relatedMemberId: string;

  @Field({ description: 'Type of relationship: PARENT, CHILD, or SPOUSE' })
  @IsEnum(['PARENT', 'CHILD', 'SPOUSE'])
  relationType: string;

  @Field({ nullable: true })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  birthDate?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  deathDate?: Date;

  @Field({ nullable: true })
  @IsOptional()
  @IsEnum(['MALE', 'FEMALE', 'OTHER'])
  gender?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  birthPlace?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;
}
