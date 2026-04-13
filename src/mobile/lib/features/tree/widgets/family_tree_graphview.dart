import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../../../core/theme/app_theme.dart';

class FamilyTreeGraphView extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final void Function(Map<String, dynamic> member)? onMemberTap;

  const FamilyTreeGraphView({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  State<FamilyTreeGraphView> createState() => _FamilyTreeGraphViewState();
}

class _FamilyTreeGraphViewState extends State<FamilyTreeGraphView> {
  final Graph _graph = Graph()..isTree = true;
  late BuchheimWalkerConfiguration _config;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _config = BuchheimWalkerConfiguration()
      ..siblingSeparation = 40
      ..levelSeparation = 80
      ..subtreeSeparation = 40
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _buildGraph();
  }

  @override
  void didUpdateWidget(FamilyTreeGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _graph.nodes.clear();
      _graph.edges.clear();
      _buildGraph();
    }
  }

  void _buildGraph() {
    if (widget.members.isEmpty) return;

    // Créer un nœud graphview par membre
    final Map<String, Node> nodeMap = {};
    for (final member in widget.members) {
      final id = member['id'] as String;
      final node = Node.Id(id);
      nodeMap[id] = node;
    }

    // Ajouter les arêtes depuis les relations
    final Set<String> addedEdges = {};
    for (final member in widget.members) {
      final relations = member['relations'] as List<dynamic>? ?? [];
      for (final rel in relations) {
        final type = rel['type'] as String? ?? '';
        final fromId = rel['fromMember']?['id'] as String?;
        final toId = rel['toMember']?['id'] as String?;
        if (fromId == null || toId == null) continue;
        if (nodeMap[fromId] == null || nodeMap[toId] == null) continue;

        // Pour l'arbre hiérarchique : PARENT → CHILD
        String parentId = fromId;
        String childId = toId;
        if (type == 'CHILD') {
          parentId = toId;
          childId = fromId;
        } else if (type == 'SPOUSE') {
          continue; // on ignore les conjoints pour le layout tree
        }

        final key = '${parentId}_$childId';
        if (!addedEdges.contains(key)) {
          _graph.addEdge(nodeMap[parentId]!, nodeMap[childId]!);
          addedEdges.add(key);
        }
      }
    }

    // Si aucune arête, ajouter tous les nœuds isolés
    if (addedEdges.isEmpty) {
      for (final node in nodeMap.values) {
        _graph.addNode(node);
      }
    }
  }

  Map<String, dynamic>? _getMemberById(String id) {
    try {
      return widget.members.firstWhere((m) => m['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.members.isEmpty) {
      return const Center(child: Text('Aucun membre'));
    }

    return InteractiveViewer(
      constrained: false,
      minScale: 0.3,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(200),
      child: GraphView(
        graph: _graph,
        algorithm: BuchheimWalkerAlgorithm(
          _config,
          TreeEdgeRenderer(_config),
        ),
        paint: Paint()
          ..color = AppTheme.primary.withValues(alpha: 0.4)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          final id = node.key?.value as String?;
          if (id == null) return const SizedBox.shrink();
          final member = _getMemberById(id);
          if (member == null) return const SizedBox.shrink();
          return _buildMemberNode(member);
        },
      ),
    );
  }

  Widget _buildMemberNode(Map<String, dynamic> member) {
    final id = member['id'] as String;
    final firstName = member['firstName'] as String? ?? '';
    final lastName = member['lastName'] as String? ?? '';
    final gender = member['gender'] as String?;
    final isDeceased = member['isDeceased'] as bool? ?? false;
    final hasLinked = member['hasLinkedProfile'] as bool? ?? false;
    final isSelected = id == _selectedId;

    final bgColor = isDeceased
        ? Colors.grey.shade200
        : isSelected
            ? AppTheme.primary
            : Colors.white;

    final textColor = isSelected ? Colors.white : Colors.black87;
    final borderColor = isSelected
        ? AppTheme.primary
        : hasLinked
            ? AppTheme.primary.withValues(alpha: 0.6)
            : Colors.grey.shade300;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedId = id == _selectedId ? null : id);
        if (widget.onMemberTap != null) widget.onMemberTap!(member);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: isSelected
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppTheme.primary.withValues(alpha: 0.12),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Infos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (gender != null) ...[
                      Icon(
                        gender == 'MALE' ? Icons.male : Icons.female,
                        size: 12,
                        color: isSelected
                            ? Colors.white70
                            : gender == 'MALE'
                                ? Colors.blue.shade300
                                : Colors.pink.shade300,
                      ),
                      const SizedBox(width: 2),
                    ],
                    if (isDeceased)
                      Text('†', style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 11)),
                    if (hasLinked)
                      Icon(Icons.verified, size: 12, color: isSelected ? Colors.white70 : AppTheme.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
