import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private supabase: SupabaseClient;

  constructor(private configService: ConfigService) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseServiceKey = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing Supabase configuration');
    }

    this.supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }

  /**
   * Récupère un utilisateur Supabase par son ID
   */
  async getUserById(userId: string) {
    const { data, error } = await this.supabase.auth.admin.getUserById(userId);
    
    if (error) {
      throw error;
    }
    
    return data.user;
  }

  /**
   * Vérifie un JWT Supabase et retourne les infos utilisateur
   */
  async verifyToken(token: string) {
    const { data, error } = await this.supabase.auth.getUser(token);
    
    if (error) {
      return null;
    }
    
    return data.user;
  }

  /**
   * Accès au client Supabase pour d'autres opérations
   */
  getClient(): SupabaseClient {
    return this.supabase;
  }
}
