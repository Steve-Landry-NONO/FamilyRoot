import { InputType, Field } from '@nestjs/graphql';
import { IsOptional, IsString, MinLength, MaxLength, IsUrl } from 'class-validator';

@InputType()
export class UpdateProfileInput {
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
  @IsUrl()
  avatarUrl?: string;
}
