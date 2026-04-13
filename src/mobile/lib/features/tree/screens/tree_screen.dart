import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/graphql/queries.dart';

class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key});
  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  List<Map<String, dynamic>> _members = [];
  String? _familyName;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final client = GraphQLService.instance.client;
      final result = await client.query(
        QueryOptions(
          document: gql(queryFamilyTree),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      final data = result.data?['familyTree'];
      if (data == null) throw Exception('Aucune famille trouvée');
      setState(() {
        _familyName = data['name'] as String?;
        _members = List<Map<String, dynamic>>.from(data['members'] ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAddMemberSheet() {
    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chargement en cours...')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMemberSheet(
        members: _members,
        onMemberAdded: _loadTree,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_familyName != null ? 'Famille $_familyName' : 'Arbre Familial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _openAddMemberSheet,
            tooltip: 'Ajouter un membre',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _openInviteSheet,
            tooltip: 'Inviter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTree,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMemberSheet,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('Erreur de chargement', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTree,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (_members.isEmpty) {
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openAddMemberSheet,
              icon: const Icon(Icons.person_add),
              label: const Text('Ajouter un membre'),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTree,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _members.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final member = _members[index];
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
                    Text(gender == 'MALE' ? 'Homme' : gender == 'FEMALE' ? 'Femme' : 'Autre',
                      style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                  ],
                  if (isDeceased)
                    const Text('† Décédé', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasLinked)
                    const Icon(Icons.verified, size: 16, color: AppTheme.primary),
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

class _AddMemberSheet extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final VoidCallback onMemberAdded;
  const _AddMemberSheet({required this.members, required this.onMemberAdded});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _relationType = 'CHILD';
  String? _relatedMemberId;
  bool _isLoading = false;

  final List<Map<String, String>> _relationTypes = [
    {'value': 'CHILD', 'label': 'Enfant'},
    {'value': 'PARENT', 'label': 'Parent'},
    {'value': 'SPOUSE', 'label': 'Conjoint(e)'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _relatedMemberId = widget.members[0]['id'] as String?;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_relatedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un membre lié')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final client = GraphQLService.instance.client;
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutationAddMember),
          variables: {
            'input': {
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'relatedMemberId': _relatedMemberId,
              'relationType': _relationType,
            },
          },
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      final added = result.data?['addMember'];
      if (added == null) throw Exception('Réponse invalide');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${added['firstName']} ${added['lastName']} ajouté(e) !'),
            backgroundColor: AppTheme.primary,
          ),
        );
        widget.onMemberAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Ajouter un membre', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relationType,
                decoration: const InputDecoration(
                  labelText: 'Type de relation',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                items: _relationTypes.map((r) => DropdownMenuItem(
                  value: r['value'],
                  child: Text(r['label']!),
                )).toList(),
                onChanged: (v) => setState(() => _relationType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _relatedMemberId,
                decoration: const InputDecoration(
                  labelText: 'Par rapport à',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                items: widget.members.map((m) => DropdownMenuItem(
                  value: m['id'] as String,
                  child: Text('${m['firstName']} ${m['lastName']}'),
                )).toList(),
                onChanged: (v) => setState(() => _relatedMemberId = v),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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

class _InviteSheet extends StatefulWidget {
  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  String? _inviteCode;
  bool _isLoading = false;

  Future<void> _generateInvite() async {
    setState(() => _isLoading = true);
    try {
      final client = GraphQLService.instance.client;
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutationCreateInvitation),
          variables: {'expiresInDays': 7},
        ),
      );
      if (result.hasException) throw Exception(result.exception.toString());
      final code = result.data?['createInvitation']?['code'] as String?;
      if (code == null) throw Exception('Code non reçu');
      setState(() => _inviteCode = code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Text("Inviter un membre", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text("Générez un code d'invitation à partager.", style: Theme.of(context).textTheme.bodyMedium),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copié !')),
                      );
                    },
                    tooltip: 'Copier',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Valable 7 jours', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateInvite,
            icon: _isLoading
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add),
            label: Text(_inviteCode == null ? "Générer un code d'invitation" : "Nouveau code"),
          ),
        ],
      ),
    );
  }
}
