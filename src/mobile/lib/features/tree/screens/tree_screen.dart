import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class TreeScreen extends ConsumerWidget {
  const TreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arbre Familial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {
              // TODO: Ouvrir le dialogue d'ajout de membre
            },
            tooltip: 'Ajouter un membre',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Partager / Inviter
            },
            tooltip: 'Inviter',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.park_outlined,
              size: 120,
              color: AppTheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Votre arbre généalogique',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'L\'arbre interactif sera affiché ici.\nCommencez par ajouter des membres !',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Ouvrir le dialogue d'ajout de membre
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter un membre'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Zoom / Centrer sur "Moi"
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
