import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/family/screens/create_family_screen.dart';
import '../../features/family/screens/join_family_screen.dart';
import '../../features/tree/screens/tree_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

/// Provider pour le router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';

      // Si pas connecté et pas sur une route auth, rediriger vers login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Si connecté et sur une route auth, rediriger vers home
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'create-family',
            name: 'createFamily',
            builder: (context, state) => const CreateFamilyScreen(),
          ),
          GoRoute(
            path: 'join-family',
            name: 'joinFamily',
            builder: (context, state) => const JoinFamilyScreen(),
          ),
          GoRoute(
            path: 'tree',
            name: 'tree',
            builder: (context, state) => const TreeScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page non trouvée: ${state.error}'),
      ),
    ),
  );
});
