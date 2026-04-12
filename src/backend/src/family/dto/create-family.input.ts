import { InputType, Field } from '@nestjs/graphql';
import { IsString, MinLength, MaxLength } from 'class-validator';

@InputType()
export class CreateFamilyInput {
  @Field({ description: 'Family name (e.g., "Famille Dupont")' })
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @Field({ description: 'Founder first name' })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  founderFirstName: string;

  @Field({ description: 'Founder last name' })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  founderLastName: string;
}
