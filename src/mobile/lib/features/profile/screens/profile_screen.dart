import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Email
              Text(
                user?.email ?? 'Utilisateur',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),

              // Options
              Card(
                child: Column(
                  children: [
                    _ProfileOption(
                      icon: Icons.edit_outlined,
                      title: 'Modifier le profil',
                      onTap: () {
                        // TODO: Éditer le profil
                      },
                    ),
                    const Divider(height: 1),
                    _ProfileOption(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        // TODO: Paramètres notifications
                      },
                    ),
                    const Divider(height: 1),
                    _ProfileOption(
                      icon: Icons.lock_outlined,
                      title: 'Changer le mot de passe',
                      onTap: () {
                        // TODO: Changer mot de passe
                      },
                    ),
                    const Divider(height: 1),
                    _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Aide',
                      onTap: () {
                        // TODO: Page aide
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Version
              Text(
                'FamilyRoots v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
