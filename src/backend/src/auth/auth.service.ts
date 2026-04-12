import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from './supabase.service';
import { Profile } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private supabaseService: SupabaseService,
  ) {}

  /**
   * Crée un profil après confirmation de l'email Supabase
   * Appelé côté client après signUp + confirmation OTP
   */
  async createProfile(
    authId: string,
    email: string,
    firstName: string,
    lastName: string,
  ): Promise<Profile> {
    // Vérifier que l'utilisateur existe dans Supabase
    const supabaseUser = await this.supabaseService.getUserById(authId);
    
    if (!supabaseUser) {
      throw new UnauthorizedException('User not found in Supabase');
    }

    if (!supabaseUser.email_confirmed_at) {
      throw new UnauthorizedException('Email not confirmed');
    }

    // Vérifier qu'un profil n'existe pas déjà
    const existingProfile = await this.prisma.profile.findUnique({
      where: { authId },
    });

    if (existingProfile) {
      throw new ConflictException('Profile already exists');
    }

    // Créer le profil
    return this.prisma.profile.create({
      data: {
        authId,
        email,
        firstName,
        lastName,
      },
    });
  }

  /**
   * Récupère le profil par authId
   */
  async getProfileByAuthId(authId: string): Promise<Profile | null> {
    return this.prisma.profile.findUnique({
      where: { authId },
      include: {
        families: {
          include: {
            family: true,
          },
        },
        linkedMember: true,
      },
    });
  }

  /**
   * Vérifie si un utilisateur a complété son profil
   */
  async hasProfile(authId: string): Promise<boolean> {
    const profile = await this.prisma.profile.findUnique({
      where: { authId },
    });
    return !!profile;
  }
}
