import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { InvitationService } from './invitation.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { InvitationType, ValidateInvitationResult } from './invitation.type';

@Resolver(() => InvitationType)
export class InvitationResolver {
  constructor(private invitationService: InvitationService) {}

  /**
   * Query: validateInvitationCode
   * Vérifie si un code d'invitation est valide
   */
  @Query(() => ValidateInvitationResult, { name: 'validateInvitationCode' })
  async validateInvitationCode(
    @Args('code') code: string,
  ): Promise<ValidateInvitationResult> {
    const result = await this.invitationService.validateCode(code);
    return {
      valid: result.valid,
      familyName: result.familyName,
      error: result.error,
    };
  }

  /**
   * Mutation: createInvitation
   * Crée une nouvelle invitation pour la famille
   */
  @Mutation(() => InvitationType)
  @UseGuards(JwtAuthGuard)
  async createInvitation(
    @CurrentUser() user: any,
    @Args('expiresInDays', { nullable: true, defaultValue: 7 }) expiresInDays: number,
  ): Promise<any> {
    // Récupérer la famille de l'utilisateur
    const userFamily = await this.invitationService['prisma'].userFamily.findFirst({
      where: { profileId: user.id },
    });

    if (!userFamily) {
      throw new Error('You must be in a family to create invitations');
    }

    return this.invitationService.createInvitation(
      user.id,
      userFamily.familyId,
      expiresInDays,
    );
  }

  /**
   * Mutation: joinFamily
   * Utilise un code d'invitation pour rejoindre une famille
   */
  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard)
  async joinFamily(
    @CurrentUser() user: any,
    @Args('code') code: string,
    @Args('firstName') firstName: string,
    @Args('lastName') lastName: string,
  ): Promise<boolean> {
    await this.invitationService.useInvitation(code, user.id, firstName, lastName);
    return true;
  }
}
