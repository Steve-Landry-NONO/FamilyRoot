import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule } from '@nestjs/config';
import { SupabaseStrategy } from './supabase.strategy';
import { AuthService } from './auth.service';
import { SupabaseService } from './supabase.service';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'supabase' }),
    ConfigModule,
  ],
  providers: [SupabaseStrategy, AuthService, SupabaseService],
  exports: [AuthService, SupabaseService],
})
export class AuthModule {}
