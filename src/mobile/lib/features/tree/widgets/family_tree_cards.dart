import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ── Modèles ──────────────────────────────────────────────────────────────────

class CardNode {
  final String id;
  final String firstName;
  final String lastName;
  final String? gender;
  final bool isDeceased;
  final bool hasLinkedProfile;
  Offset position;

  CardNode({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.isDeceased = false,
    this.hasLinkedProfile = false,
    this.position = Offset.zero,
  });
}

class CardEdge {
  final String fromId;
  final String toId;
  final String type;
  CardEdge({required this.fromId, required this.toId, required this.type});
}

// ── Layout ───────────────────────────────────────────────────────────────────

class CardTreeLayout {
  static const double cardW = 140.0;
  static const double cardH = 72.0;
  static const double hGap = 32.0;
  static const double vGap = 80.0;

  static void compute(List<CardNode> nodes, List<CardEdge> edges) {
    if (nodes.isEmpty) return;
    final Map<String, List<String>> children = {for (var n in nodes) n.id: []};
    final Set<String> hasParent = {};
    for (final e in edges) {
      if (e.type == 'PARENT') {
        children[e.fromId]?.add(e.toId);
        hasParent.add(e.toId);
      } else if (e.type == 'CHILD') {
        children[e.toId]?.add(e.fromId);
        hasParent.add(e.fromId);
      }
    }
    final roots = nodes.where((n) => !hasParent.contains(n.id)).toList();
    if (roots.isEmpty) roots.add(nodes.first);
    double x = 0;
    for (final root in roots) {
      x = _layout(root.id, nodes, children, 0, x);
    }
    _center(nodes);
  }

  static double _layout(String id, List<CardNode> nodes,
      Map<String, List<String>> children, int depth, double xStart) {
    final node = nodes.firstWhere((n) => n.id == id);
    final kids = children[id] ?? [];
    if (kids.isEmpty) {
      node.position = Offset(xStart, depth * (cardH + vGap));
      return xStart + cardW + hGap;
    }
    double xEnd = xStart;
    for (final kid in kids) {
      xEnd = _layout(kid, nodes, children, depth + 1, xEnd);
    }
    final first = nodes.firstWhere((n) => n.id == kids.first);
    final last = nodes.firstWhere((n) => n.id == kids.last);
    node.position = Offset(
      (first.position.dx + last.position.dx) / 2,
      depth * (cardH + vGap),
    );
    return xEnd;
  }

  static void _center(List<CardNode> nodes) {
    if (nodes.isEmpty) return;
    final minX = nodes.map((n) => n.position.dx).reduce((a, b) => a < b ? a : b);
    final minY = nodes.map((n) => n.position.dy).reduce((a, b) => a < b ? a : b);
    for (final n in nodes) {
      n.position = Offset(n.position.dx - minX + 60, n.position.dy - minY + 60);
    }
  }

  static Size canvasSize(List<CardNode> nodes) {
    if (nodes.isEmpty) return const Size(400, 400);
    final maxX = nodes.map((n) => n.position.dx).reduce((a, b) => a > b ? a : b);
    final maxY = nodes.map((n) => n.position.dy).reduce((a, b) => a > b ? a : b);
    return Size(maxX + cardW + 60, maxY + cardH + 60);
  }
}

// ── Painter des connexions ────────────────────────────────────────────────────

class EdgePainter extends CustomPainter {
  final List<CardNode> nodes;
  final List<CardEdge> edges;

  EdgePainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    const w = CardTreeLayout.cardW;
    const h = CardTreeLayout.cardH;

    for (final edge in edges) {
      if (edge.type == 'SPOUSE') continue;
      final from = nodes.firstWhere((n) => n.id == edge.fromId, orElse: () => nodes.first);
      final to = nodes.firstWhere((n) => n.id == edge.toId, orElse: () => nodes.first);

      final fromCenter = Offset(from.position.dx + w / 2, from.position.dy + h);
      final toCenter = Offset(to.position.dx + w / 2, to.position.dy);

      final paint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(fromCenter.dx, fromCenter.dy)
        ..cubicTo(
          fromCenter.dx, fromCenter.dy + 30,
          toCenter.dx, toCenter.dy - 30,
          toCenter.dx, toCenter.dy,
        );
      canvas.drawPath(path, paint);

      // Flèche
      final arrowPaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      final tip = toCenter;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - 5, tip.dy - 8)
          ..lineTo(tip.dx + 5, tip.dy - 8)
          ..close(),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(EdgePainter oldDelegate) => oldDelegate.nodes != nodes || oldDelegate.edges != edges;
}

// ── Widget principal ──────────────────────────────────────────────────────────

class FamilyTreeCards extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final void Function(Map<String, dynamic>)? onMemberTap;

  const FamilyTreeCards({
    super.key,
    required this.members,
    this.onMemberTap,
  });

  @override
  State<FamilyTreeCards> createState() => _FamilyTreeCardsState();
}

class _FamilyTreeCardsState extends State<FamilyTreeCards> {
  late List<CardNode> _nodes;
  late List<CardEdge> _edges;
  late Size _canvasSize;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(FamilyTreeCards old) {
    super.didUpdateWidget(old);
    if (old.members != widget.members) _build();
  }

  void _build() {
    _nodes = widget.members.map((m) => CardNode(
      id: m['id'] as String,
      firstName: m['firstName'] as String? ?? '',
      lastName: m['lastName'] as String? ?? '',
      gender: m['gender'] as String?,
      isDeceased: m['isDeceased'] as bool? ?? false,
      hasLinkedProfile: m['hasLinkedProfile'] as bool? ?? false,
    )).toList();

    final Set<String> seen = {};
    _edges = [];
    for (final m in widget.members) {
      for (final rel in (m['relations'] as List<dynamic>? ?? [])) {
        final type = rel['type'] as String? ?? '';
        final fromId = rel['fromMember']?['id'] as String?;
        final toId = rel['toMember']?['id'] as String?;
        if (fromId == null || toId == null) continue;
        final key = '${fromId}_$toId';
        if (!seen.contains(key) && !seen.contains('${toId}_$fromId')) {
          _edges.add(CardEdge(fromId: fromId, toId: toId, type: type));
          seen.add(key);
        }
      }
    }

    CardTreeLayout.compute(_nodes, _edges);
    _canvasSize = CardTreeLayout.canvasSize(_nodes);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      minScale: 0.3,
      maxScale: 3.0,
      boundaryMargin: const EdgeInsets.all(300),
      child: SizedBox(
        width: _canvasSize.width,
        height: _canvasSize.height,
        child: Stack(
          children: [
            // Lignes de connexion
            Positioned.fill(
              child: CustomPaint(
                painter: EdgePainter(nodes: _nodes, edges: _edges),
              ),
            ),
            // Cartes membres
            ..._nodes.map((node) {
              final member = widget.members.firstWhere(
                (m) => m['id'] == node.id,
                orElse: () => {},
              );
              final isSelected = node.id == _selectedId;
              return Positioned(
                left: node.position.dx,
                top: node.position.dy,
                width: CardTreeLayout.cardW,
                height: CardTreeLayout.cardH,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedId = node.id == _selectedId ? null : node.id);
                    if (member.isNotEmpty) widget.onMemberTap?.call(member);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : node.hasLinkedProfile
                            ? AppTheme.primary.withValues(alpha: 0.5)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppTheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              node.firstName.isNotEmpty ? node.firstName[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  node.firstName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  node.lastName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  children: [
                                    if (node.gender != null)
                                      Icon(
                                        node.gender == 'MALE' ? Icons.male : Icons.female,
                                        size: 12,
                                        color: isSelected ? Colors.white70
                                            : node.gender == 'MALE' ? Colors.blue.shade300
                                            : Colors.pink.shade300,
                                      ),
                                    if (node.isDeceased)
                                      Text('†', style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? Colors.white70 : Colors.grey,
                                      )),
                                    if (node.hasLinkedProfile)
                                      Icon(Icons.verified, size: 11,
                                        color: isSelected ? Colors.white70 : AppTheme.primary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
