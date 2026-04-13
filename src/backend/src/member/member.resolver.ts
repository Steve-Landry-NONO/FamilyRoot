import { Resolver, Query, Mutation, Args, ResolveField, Parent } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { MemberService } from './member.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { MemberType, RelationshipType } from './member.type';
import { AddMemberInput } from './dto/add-member.input';
import { UpdateMemberInput } from './dto/update-member.input';

@Resolver(() => MemberType)
export class MemberResolver {
  constructor(private memberService: MemberService, private prisma: PrismaService) {}

  @Query(() => MemberType, { name: 'member', nullable: true })
  @UseGuards(JwtAuthGuard)
  async member(@Args('id') id: string): Promise<any> {
    return this.memberService.findById(id);
  }

  @ResolveField('relations', () => [RelationshipType], { nullable: true })
  async relations(@Parent() member: any): Promise<any[]> {
    return this.prisma.relationship.findMany({
      where: {
        OR: [
          { fromMemberId: member.id },
          { toMemberId: member.id },
        ],
      },
      include: {
        fromMember: true,
        toMember: true,
      },
    });
  }

  @ResolveField('hasLinkedProfile', () => Boolean, { nullable: true })
  hasLinkedProfile(@Parent() member: any): boolean {
    return member.linkedProfileId != null;
  }

  @ResolveField('isDeceased', () => Boolean, { nullable: true })
  isDeceased(@Parent() member: any): boolean {
    return member.deathDate != null;
  }

  @Mutation(() => MemberType)
  @UseGuards(JwtAuthGuard)
  async addMember(
    @CurrentUser() user: any,
    @Args('input') input: AddMemberInput,
  ): Promise<any> {
    const userFamily = await this.memberService['prisma'].userFamily.findFirst({
      where: { profileId: user.id },
    });
    if (!userFamily) throw new Error('You must be in a family to add members');
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

  @Mutation(() => MemberType)
  @UseGuards(JwtAuthGuard)
  async updateMember(
    @CurrentUser() user: any,
    @Args('id') id: string,
    @Args('input') input: UpdateMemberInput,
  ): Promise<any> {
    const userFamily = await this.memberService['prisma'].userFamily.findFirst({
      where: { profileId: user.id },
    });
    if (!userFamily) throw new Error('You must be in a family to update members');
    return this.memberService.updateMember(id, userFamily.familyId, input);
  }
}
