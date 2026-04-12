import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { MemberService } from './member.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { MemberType } from './member.type';
import { AddMemberInput } from './dto/add-member.input';
import { UpdateMemberInput } from './dto/update-member.input';

@Resolver(() => MemberType)
export class MemberResolver {
  constructor(private memberService: MemberService) {}

  /**
   * Query: member
   * Récupère un membre par ID
   */
  @Query(() => MemberType, { name: 'member', nullable: true })
  @UseGuards(JwtAuthGuard)
  async member(@Args('id') id: string): Promise<any> {
    return this.memberService.findById(id);
  }

  /**
   * Mutation: addMember
   * Ajoute un nouveau membre à la famille
   */
  @Mutation(() => MemberType)
  @UseGuards(JwtAuthGuard)
  async addMember(
    @CurrentUser() user: any,
    @Args('input') input: AddMemberInput,
  ): Promise<any> {
    // Récupérer la famille de l'utilisateur
    const userFamily = await this.memberService['prisma'].userFamily.findFirst({
      where: { profileId: user.id },
    });

    if (!userFamily) {
      throw new Error('You must be in a family to add members');
    }

    return this.memberService.addMember(userFamily.familyId, {
      firstName: input.firstName,
      lastName: input.lastName,
      relatedMemberId: input.relatedMemberId,
      relationType: input.relationType as any,
      birthDate: input.birthDate,
      deathDate: input.deathDate,
      gender: input.gender as any,
      birthPlace: input.birthPlace,
      bio: input.bio,
    });
  }

  /**
   * Mutation: updateMember
   * Met à jour un membre
   */
  @Mutation(() => MemberType)
  @UseGuards(JwtAuthGuard)
  async updateMember(
    @CurrentUser() user: any,
    @Args('id') id: string,
    @Args('input') input: UpdateMemberInput,
  ): Promise<any> {
    // Récupérer la famille de l'utilisateur
    const userFamily = await this.memberService['prisma'].userFamily.findFirst({
      where: { profileId: user.id },
    });

    if (!userFamily) {
      throw new Error('You must be in a family to update members');
    }

    return this.memberService.updateMember(id, userFamily.familyId, input);
  }
}
