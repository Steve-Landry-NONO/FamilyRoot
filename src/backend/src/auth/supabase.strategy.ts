import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SupabaseStrategy extends PassportStrategy(Strategy, 'supabase') {
  constructor(private prisma: PrismaService) {
    const jwtSecret = process.env.SUPABASE_JWT_SECRET;
    if (!jwtSecret) {
      throw new Error('SUPABASE_JWT_SECRET is not defined');
    }

    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtSecret,
      audience: 'authenticated',
    });
  }

  async validate(payload: any) {
    const authId = payload.sub;

    if (!authId) {
      throw new UnauthorizedException('Invalid token');
    }

    // Chercher le profil par authId (UUID de auth.users)
    let profile = await this.prisma.profile.findUnique({
      where: { authId },
    });

    // Si pas trouvé, créer un nouveau profil
    if (!profile) {
      profile = await this.prisma.profile.create({
        data: {
          authId,
          email: payload.email || '',
          firstName: '',
          lastName: '',
        },
      });
    }

    return profile;
  }
}
