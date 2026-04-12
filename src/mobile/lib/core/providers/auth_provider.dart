import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Provider pour la session actuelle
final currentSessionProvider = Provider<Session?>((ref) {
  return Supabase.instance.client.auth.currentSession;
});

/// Service d'authentification
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Inscription avec email/password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'familyroots://auth-callback',
    );
  }

  /// Connexion avec email/password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'familyroots://auth-callback',
    );
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => _client.auth.currentSession != null;

  /// Obtenir le token JWT
  String? get accessToken => _client.auth.currentSession?.accessToken;
}

/// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});
