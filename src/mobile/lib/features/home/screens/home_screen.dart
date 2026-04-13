import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/graphql/queries.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final client = GraphQLService.instance.client;
      final result = await client.query(
        QueryOptions(
          document: gql(queryMe),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      setState(() => _profile = result.data?['me'] as Map<String, dynamic>?);
    } catch (_) {
      // silencieux — on garde les infos Supabase en fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final hasFamily = _profile?['hasFamily'] as bool? ?? false;
    final firstName = _profile?['firstName'] as String?;
    final lastName = _profile?['lastName'] as String?;
    final displayName = (firstName != null && firstName.isNotEmpty)
        ? '$firstName${lastName != null ? ' $lastName' : ''}'
        : user?.email ?? 'Utilisateur';
    final initial = (firstName?.isNotEmpty == true)
        ? firstName![0].toUpperCase()
        : (user?.email?[0].toUpperCase() ?? '?');

    return Scaffold(
      appBar: AppBar(
        title: const Text('FamilyRoots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte profil
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenue !',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                  Text(
                                    displayName,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (hasFamily)
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: AppTheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Membre d\'une famille',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primary),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _loadProfile,
                              tooltip: 'Rafraîchir',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section principale selon état famille
                    if (hasFamily) ...[
                      Text('Mon espace', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _ActionCard(
                        icon: Icons.park_outlined,
                        title: 'Voir l\'arbre familial',
                        subtitle: 'Explorez votre arbre généalogique',
                        color: AppTheme.primary,
                        onTap: () => context.go('/tree'),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.group_add_outlined,
                        title: 'Inviter un membre',
                        subtitle: 'Partagez un code d\'invitation',
                        color: Colors.teal,
                        onTap: () => context.go('/tree'),
                      ),
                    ] else ...[
                      Text('Commencer', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      _ActionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Créer une famille',
                        subtitle: 'Démarrez votre arbre généalogique',
                        color: AppTheme.primary,
                        onTap: () => context.go('/create-family'),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.group_add_outlined,
                        title: 'Rejoindre une famille',
                        subtitle: 'Utilisez un code d\'invitation',
                        color: Colors.teal,
                        onTap: () => context.go('/join-family'),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Déconnexion
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final authService = ref.read(authServiceProvider);
                          await authService.signOut();
                          if (context.mounted) context.go('/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Se déconnecter'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
