import { InputType, Field } from '@nestjs/graphql';
import { IsString, MinLength, MaxLength, IsOptional, IsDate, IsUrl, IsIn } from 'class-validator';
import { Type } from 'class-transformer';

@InputType()
export class UpdateMemberInput {
  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  firstName?: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  lastName?: string;

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
  @IsIn(['MALE', 'FEMALE', 'OTHER'])
  gender?: 'MALE' | 'FEMALE' | 'OTHER';

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

  @Field({ nullable: true })
  @IsOptional()
  @IsUrl()
  photoUrl?: string;
}
