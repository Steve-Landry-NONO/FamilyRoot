import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../family/providers/family_provider.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});
  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _familyNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _familyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateFamily() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(familyProvider.notifier).createFamily(
      familyName: _familyNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final family = ref.read(familyProvider).family;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Famille "${family?['name']}" créée ! Code : ${family?['code']}'),
          backgroundColor: AppTheme.primary,
        ),
      );
      context.go('/tree');
    } else {
      final error = ref.read(familyProvider).error ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $error'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer une famille')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.family_restroom, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Créez votre arbre familial',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Donnez un nom à votre famille et ajoutez-vous comme premier membre',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _familyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la famille',
                    prefixIcon: Icon(Icons.home_outlined),
                    hintText: 'Ex: Famille Dupont',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Veuillez entrer le nom de la famille';
                    if (value.trim().length < 2) return 'Le nom doit contenir au moins 2 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Vos informations', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre prénom';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Veuillez entrer votre nom';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleCreateFamily,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Créer la famille'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
