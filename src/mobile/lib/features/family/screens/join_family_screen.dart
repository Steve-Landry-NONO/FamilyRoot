import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/graphql/queries.dart';

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
  bool _isLoading = false;
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
      final client = GraphQLService.instance.client;
      final result = await client.query(
        QueryOptions(
          document: gql(queryValidateInvitation),
          variables: {'code': code},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      final data = result.data?['validateInvitationCode'];
      if (data == null) throw Exception('Réponse invalide');
      if (data['valid'] == true) {
        setState(() {
          _familyName = data['familyName'] as String?;
          _validatedCode = code;
        });
      } else {
        final error = data['error'] as String? ?? 'Code invalide';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppTheme.error),
          );
        }
        setState(() { _familyName = null; _validatedCode = null; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: \${e.toString()}'), backgroundColor: AppTheme.error),
        );
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
    setState(() => _isLoading = true);
    try {
      final client = GraphQLService.instance.client;
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutationJoinFamily),
          variables: {
            'code': _validatedCode,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
          },
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      final success = result.data?['joinFamily'] as bool? ?? false;
      if (!success) throw Exception('Impossible de rejoindre la famille');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vous avez rejoint \$_familyName !'),
            backgroundColor: AppTheme.primary,
          ),
        );
        context.go('/tree');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: \${e.toString()}'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    hintText: 'FAM-XXXXXXX',
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
                    onPressed: _isLoading ? null : _handleJoinFamily,
                    child: _isLoading
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
