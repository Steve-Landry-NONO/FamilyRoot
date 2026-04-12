import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { FamilyService } from './family.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { Profile } from '@prisma/client';
import { FamilyType, DashboardType } from './family.type';
import { CreateFamilyInput } from './dto/create-family.input';

@Resolver(() => FamilyType)
export class FamilyResolver {
  constructor(private familyService: FamilyService) {}

  /**
   * Query: dashboard
   * Retourne les stats du dashboard pour la famille de l'utilisateur
   */
  @Query(() => DashboardType, { name: 'dashboard', nullable: true })
  @UseGuards(JwtAuthGuard)
  async dashboard(@CurrentUser() user: Profile) {
    const family = await this.familyService.getUserFamily(user.id);
    
    if (!family) {
      return null;
    }

    const stats = await this.familyService.getDashboardStats(family.id);

    return {
      family,
      ...stats,
    };
  }

  /**
   * Query: familyTree
   * Retourne l'arbre généalogique complet
   */
  @Query(() => FamilyType, { name: 'familyTree', nullable: true })
  @UseGuards(JwtAuthGuard)
  async familyTree(@CurrentUser() user: Profile) {
    return this.familyService.getUserFamily(user.id);
  }

  /**
   * Mutation: createFamily
   * Crée une nouvelle famille (MVP : 1 seule par utilisateur)
   */
  @Mutation(() => FamilyType)
  @UseGuards(JwtAuthGuard)
  async createFamily(
    @CurrentUser() user: Profile,
    @Args('input') input: CreateFamilyInput,
  ) {
    return this.familyService.createFamily(
      user,
      input.name,
      input.founderFirstName,
      input.founderLastName,
    );
  }
}
