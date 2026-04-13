import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../family/providers/family_provider.dart';
import '../../member/providers/member_provider.dart';

class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key});
  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(familyProvider.notifier).loadFamilyTree());
  }

  void _openAddMemberSheet(List<dynamic> members) {
    if (members.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMemberSheet(
        members: members,
        onMemberAdded: () => ref.read(familyProvider.notifier).loadFamilyTree(),
      ),
    );
  }

  void _openInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InviteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);
    final familyName = state.family?['name'] as String?;
    final members = state.members ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(familyName != null ? 'Famille $familyName' : 'Arbre Familial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: members.isEmpty ? null : () => _openAddMemberSheet(members),
            tooltip: 'Ajouter un membre',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _openInviteSheet,
            tooltip: 'Inviter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(familyProvider.notifier).loadFamilyTree(),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(state, members),
      floatingActionButton: FloatingActionButton(
        onPressed: members.isEmpty ? null : () => _openAddMemberSheet(members),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildBody(FamilyState state, List<dynamic> members) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(familyProvider.notifier).loadFamilyTree(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park_outlined, size: 120, color: AppTheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text('Votre arbre généalogique', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "L'arbre interactif sera affiché ici.\nCommencez par ajouter des membres !",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(familyProvider.notifier).loadFamilyTree(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final member = members[index] as Map<String, dynamic>;
          final firstName = member['firstName'] as String? ?? '';
          final lastName = member['lastName'] as String? ?? '';
          final gender = member['gender'] as String?;
          final isDeceased = member['isDeceased'] as bool? ?? false;
          final hasLinked = member['hasLinkedProfile'] as bool? ?? false;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text('$firstName $lastName'),
              subtitle: Row(
                children: [
                  if (gender != null) ...[
                    Icon(
                      gender == 'MALE' ? Icons.male : gender == 'FEMALE' ? Icons.female : Icons.person,
                      size: 14, color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gender == 'MALE' ? 'Homme' : gender == 'FEMALE' ? 'Femme' : 'Autre',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (isDeceased)
                    const Text('† Décédé', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasLinked) const Icon(Icons.verified, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Bottom Sheet : Ajouter un membre ─────────────────────────────────────────

class _AddMemberSheet extends ConsumerStatefulWidget {
  final List<dynamic> members;
  final VoidCallback onMemberAdded;
  const _AddMemberSheet({required this.members, required this.onMemberAdded});
  @override
  ConsumerState<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<_AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _relationType = 'CHILD';
  String? _relatedMemberId;

  final List<Map<String, String>> _relationTypes = [
    {'value': 'CHILD',  'label': 'Enfant'},
    {'value': 'PARENT', 'label': 'Parent'},
    {'value': 'SPOUSE', 'label': 'Conjoint(e)'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _relatedMemberId = (widget.members[0] as Map<String, dynamic>)['id'] as String?;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _relatedMemberId == null) return;

    final success = await ref.read(memberProvider.notifier).addMember(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      relatedMemberId: _relatedMemberId!,
      relationType: _relationType,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      final state = ref.read(memberProvider);
      final added = state.member;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${added?['firstName'] ?? ''} ${added?['lastName'] ?? ''} ajouté(e) !'),
          backgroundColor: AppTheme.primary,
        ),
      );
      widget.onMemberAdded();
    } else {
      final error = ref.read(memberProvider).error ?? 'Erreur inconnue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(memberProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ajouter un membre', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationType,
                decoration: const InputDecoration(labelText: 'Type de relation', prefixIcon: Icon(Icons.family_restroom)),
                items: _relationTypes.map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!))).toList(),
                onChanged: (v) => setState(() => _relationType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relatedMemberId,
                decoration: const InputDecoration(labelText: 'Par rapport à', prefixIcon: Icon(Icons.people_outline)),
                items: widget.members.map((m) {
                  final member = m as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: member['id'] as String,
                    child: Text('${member['firstName']} ${member['lastName']}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _relatedMemberId = v),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Sheet : Inviter ────────────────────────────────────────────────────

class _InviteSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  String? _inviteCode;

  Future<void> _generateInvite() async {
    final code = await ref.read(familyProvider.notifier).createInvitation();
    if (mounted) setState(() => _inviteCode = code);
    if (code == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la génération')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Inviter un membre', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Générez un code d\'invitation à partager.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          if (_inviteCode != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteCode!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copié !'))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Valable 7 jours', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: isLoading ? null : _generateInvite,
            icon: isLoading
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add),
            label: Text(_inviteCode == null ? 'Générer un code d\'invitation' : 'Nouveau code'),
          ),
        ],
      ),
    );
  }
}
