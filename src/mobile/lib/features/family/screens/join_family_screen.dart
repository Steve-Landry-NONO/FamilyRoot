import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../family/providers/family_provider.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});
  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isValidating = false;
  String? _familyName;
  String? _validatedCode;

  @override
  void dispose() {
    _codeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _isValidating = true);
    try {
      final result = await ref.read(familyProvider.notifier).validateInvitationCode(code);
      if (result != null && result['valid'] == true) {
        setState(() {
          _familyName = result['familyName'] as String?;
          _validatedCode = code;
        });
      } else {
        final error = result?['error'] as String? ?? 'Code invalide';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.error),
          );
        }
        setState(() { _familyName = null; _validatedCode = null; });
      }
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  Future<void> _handleJoinFamily() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validatedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord valider le code')),
      );
      return;
    }

    final success = await ref.read(familyProvider.notifier).joinFamily(
      code: _validatedCode!,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous avez rejoint $_familyName !'),
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
      appBar: AppBar(title: const Text('Rejoindre une famille')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.group_add, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Rejoignez votre famille',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez le code d\'invitation reçu',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Code d\'invitation',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    hintText: 'INV-XXXXXXXXXXXX',
                    suffixIcon: _isValidating
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: _validateCode,
                            tooltip: 'Valider le code',
                          ),
                  ),
                  onChanged: (value) {
                    if (_familyName != null) {
                      setState(() { _familyName = null; _validatedCode = null; });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer le code d\'invitation';
                    return null;
                  },
                ),
                if (_familyName != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Famille trouvée !'),
                                Text(_familyName!, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      if (value == null || value.isEmpty) return 'Veuillez entrer votre prénom';
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
                      if (value == null || value.isEmpty) return 'Veuillez entrer votre nom';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleJoinFamily,
                    child: isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Rejoindre la famille'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
