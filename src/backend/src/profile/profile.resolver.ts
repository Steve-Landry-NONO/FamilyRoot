import { Resolver, Query, Mutation, Args, ResolveField, Parent } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { Profile as ProfileModel } from '@prisma/client';
import { ProfileType } from './profile.type';
import { UpdateProfileInput } from './dto/update-profile.input';

@Resolver(() => ProfileType)
export class ProfileResolver {
  constructor(private profileService: ProfileService) {}

  @Query(() => ProfileType, { name: 'me', description: 'Get current user profile' })
  @UseGuards(JwtAuthGuard)
  async me(@CurrentUser() user: ProfileModel): Promise<ProfileModel> {
    return this.profileService.findById(user.id);
  }

  @ResolveField('hasFamily', () => Boolean)
  async hasFamily(@Parent() profile: ProfileModel): Promise<boolean> {
    return this.profileService.hasFamily(profile.id);
  }

  @Mutation(() => ProfileType, { description: 'Update current user profile' })
  @UseGuards(JwtAuthGuard)
  async updateProfile(
    @CurrentUser() user: ProfileModel,
    @Args('input') input: UpdateProfileInput,
  ): Promise<ProfileModel> {
    return this.profileService.update(user.id, input);
  }

  @Mutation(() => ProfileType, { description: 'Update FCM token for push notifications' })
  @UseGuards(JwtAuthGuard)
  async updateFcmToken(
    @CurrentUser() user: ProfileModel,
    @Args('token') token: string,
  ): Promise<ProfileModel> {
    return this.profileService.updateFcmToken(user.id, token);
  }
}
