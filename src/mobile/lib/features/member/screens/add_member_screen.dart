import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/member_provider.dart';
import '../../family/providers/family_provider.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  final String? relatedMemberId;
  
  const AddMemberScreen({super.key, this.relatedMemberId});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _bioController = TextEditingController();
  
  DateTime? _birthDate;
  DateTime? _deathDate;
  String _gender = 'MALE';
  String _relationType = 'CHILD';
  bool _isDeceased = false;

  final List<Map<String, String>> _relationTypes = [
    {'value': 'FATHER', 'label': 'Père'},
    {'value': 'MOTHER', 'label': 'Mère'},
    {'value': 'CHILD', 'label': 'Enfant'},
    {'value': 'SPOUSE', 'label': 'Conjoint(e)'},
    {'value': 'SIBLING', 'label': 'Frère/Sœur'},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthPlaceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.background,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _deathDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleAddMember() async {
    if (!_formKey.currentState!.validate()) return;

    // Récupérer l'ID du membre lié (soit passé en param, soit le premier membre de la famille)
    String? relatedMemberId = widget.relatedMemberId;
    
    if (relatedMemberId == null) {
      // Si pas d'ID fourni, on doit en avoir un depuis la famille
      final familyState = ref.read(familyProvider);
      if (familyState.members != null && familyState.members!.isNotEmpty) {
        relatedMemberId = familyState.members![0]['id'];
      }
    }

    if (relatedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: Aucun membre de référence trouvé'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final success = await ref.read(memberProvider.notifier).addMember(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      relatedMemberId: relatedMemberId,
      relationType: _relationType,
      birthDate: _birthDate,
      deathDate: _isDeceased ? _deathDate : null,
      gender: _gender,
      birthPlace: _birthPlaceController.text.trim().isNotEmpty 
          ? _birthPlaceController.text.trim() 
          : null,
      bio: _bioController.text.trim().isNotEmpty 
          ? _bioController.text.trim() 
          : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membre ajouté avec succès !'),
            backgroundColor: AppTheme.primary,
          ),
        );
        // Recharger l'arbre et retourner
        await ref.read(familyProvider.notifier).loadFamilyTree();
        if (mounted) context.pop();
      } else {
        final error = ref.read(memberProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Erreur lors de l\'ajout'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(memberProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un membre'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: Icon(
                          _gender == 'MALE' ? Icons.person : Icons.person_2,
                          size: 50,
                          color: AppTheme.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.secondary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Colors.white,
                            onPressed: () {
                              // TODO: Ajouter photo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ajout de photo bientôt disponible'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations de base
                Text(
                  'Informations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nom
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Genre
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Homme')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Femme')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _gender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Type de relation
                DropdownButtonFormField<String>(
                  value: _relationType,
                  decoration: const InputDecoration(
                    labelText: 'Relation avec vous *',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  items: _relationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _relationType = value);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Dates
                Text(
                  'Dates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Date de naissance
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Date de naissance'),
                  subtitle: Text(_formatDate(_birthDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                const Divider(),

                // Décédé ?
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Personne décédée'),
                  value: _isDeceased,
                  onChanged: (value) {
                    setState(() {
                      _isDeceased = value;
                      if (!value) _deathDate = null;
                    });
                  },
                  activeColor: AppTheme.primary,
                ),

                // Date de décès
                if (_isDeceased) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Date de décès'),
                    subtitle: Text(_formatDate(_deathDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                  const Divider(),
                ],
                const SizedBox(height: 16),

                // Informations optionnelles
                Text(
                  'Informations complémentaires',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Lieu de naissance
                TextFormField(
                  controller: _birthPlaceController,
                  decoration: const InputDecoration(
                    labelText: 'Lieu de naissance',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Bio
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Biographie',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton ajouter
                ElevatedButton.icon(
                  onPressed: memberState.isLoading ? null : _handleAddMember,
                  icon: memberState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(memberState.isLoading ? 'Ajout...' : 'Ajouter le membre'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
