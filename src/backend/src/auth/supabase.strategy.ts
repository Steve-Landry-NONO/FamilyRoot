import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-custom';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from './supabase.service';

@Injectable()
export class SupabaseStrategy extends PassportStrategy(Strategy, 'supabase') {
  constructor(
    private prisma: PrismaService,
    private supabaseService: SupabaseService,
  ) {
    super();
  }

  async validate(req: any) {
    const authHeader = req.headers?.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('No token provided');
    }

    const token = authHeader.substring(7);

    // Vérification via Supabase (gère ES256 nativement)
    const supabaseUser = await this.supabaseService.verifyToken(token);
    if (!supabaseUser) {
      throw new UnauthorizedException('Invalid token');
    }

    const authId = supabaseUser.id;

    // Récupérer ou créer le profil
    let profile = await this.prisma.profile.findUnique({
      where: { authId },
    });

    if (!profile) {
      profile = await this.prisma.profile.create({
        data: {
          authId,
          email: supabaseUser.email || '',
          firstName: '',
          lastName: '',
        },
      });
    }

    return profile;
  }
}
