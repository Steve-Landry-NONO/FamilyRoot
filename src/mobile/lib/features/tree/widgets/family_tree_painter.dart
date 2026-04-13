import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ── Modèle nœud ──────────────────────────────────────────────────────────────

class TreeNode {
  final String id;
  final String firstName;
  final String lastName;
  final String? gender;
  final bool isDeceased;
  final bool hasLinkedProfile;
  Offset position;

  TreeNode({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.isDeceased = false,
    this.hasLinkedProfile = false,
    this.position = Offset.zero,
  });

  String get displayName => '$firstName\n$lastName';
  String get initial => firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
}

class TreeEdge {
  final String fromId;
  final String toId;
  final String type; // PARENT, CHILD, SPOUSE

  TreeEdge({required this.fromId, required this.toId, required this.type});
}

// ── Layout algorithme ────────────────────────────────────────────────────────

class TreeLayout {
  static const double nodeRadius = 36.0;
  static const double horizontalSpacing = 120.0;
  static const double verticalSpacing = 140.0;

  /// Calcule les positions des nœuds en arbre hiérarchique
  static void compute(List<TreeNode> nodes, List<TreeEdge> edges) {
    if (nodes.isEmpty) return;

    // Construire map parent → enfants
    final Map<String, List<String>> children = {};
    final Set<String> hasParent = {};

    for (final node in nodes) {
      children[node.id] = [];
    }

    for (final edge in edges) {
      if (edge.type == 'PARENT') {
        // fromId est parent de toId
        children[edge.fromId]?.add(edge.toId);
        hasParent.add(edge.toId);
      } else if (edge.type == 'CHILD') {
        // fromId est enfant de toId
        children[edge.toId]?.add(edge.fromId);
        hasParent.add(edge.fromId);
      }
    }

    // Trouver les racines (nœuds sans parent)
    final roots = nodes.where((n) => !hasParent.contains(n.id)).toList();
    if (roots.isEmpty) roots.add(nodes.first);

    // Positionner récursivement
    double xOffset = 0;
    for (final root in roots) {
      xOffset = _positionSubtree(root.id, nodes, children, 0, xOffset);
    }

    // Centrer verticalement
    _centerLayout(nodes);
  }

  static double _positionSubtree(
    String nodeId,
    List<TreeNode> nodes,
    Map<String, List<String>> children,
    int depth,
    double xStart,
  ) {
    final node = nodes.firstWhere((n) => n.id == nodeId, orElse: () => nodes.first);
    final kids = children[nodeId] ?? [];

    if (kids.isEmpty) {
      node.position = Offset(xStart, depth * verticalSpacing);
      return xStart + horizontalSpacing;
    }

    double xEnd = xStart;
    for (final childId in kids) {
      xEnd = _positionSubtree(childId, nodes, children, depth + 1, xEnd);
    }

    // Centrer le parent sur ses enfants
    final firstChild = nodes.firstWhere((n) => n.id == kids.first);
    final lastChild = nodes.firstWhere((n) => n.id == kids.last);
    final centerX = (firstChild.position.dx + lastChild.position.dx) / 2;
    node.position = Offset(centerX, depth * verticalSpacing);

    return xEnd;
  }

  static void _centerLayout(List<TreeNode> nodes) {
    if (nodes.isEmpty) return;
    final minX = nodes.map((n) => n.position.dx).reduce((a, b) => a < b ? a : b);
    final minY = nodes.map((n) => n.position.dy).reduce((a, b) => a < b ? a : b);
    const padding = 80.0;
    for (final node in nodes) {
      node.position = Offset(
        node.position.dx - minX + padding,
        node.position.dy - minY + padding,
      );
    }
  }

  static Size computeCanvasSize(List<TreeNode> nodes) {
    if (nodes.isEmpty) return const Size(400, 400);
    final maxX = nodes.map((n) => n.position.dx).reduce((a, b) => a > b ? a : b);
    final maxY = nodes.map((n) => n.position.dy).reduce((a, b) => a > b ? a : b);
    return Size(maxX + 120, maxY + 120);
  }
}

// ── CustomPainter ────────────────────────────────────────────────────────────

class FamilyTreePainter extends CustomPainter {
  final List<TreeNode> nodes;
  final List<TreeEdge> edges;
  final String? selectedId;

  FamilyTreePainter({
    required this.nodes,
    required this.edges,
    this.selectedId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas);
    _drawNodes(canvas);
  }

  void _drawEdges(Canvas canvas) {
    for (final edge in edges) {
      final from = nodes.firstWhere((n) => n.id == edge.fromId, orElse: () => nodes.first);
      final to = nodes.firstWhere((n) => n.id == edge.toId, orElse: () => nodes.first);

      Color edgeColor;
      bool isDashed = false;
      switch (edge.type) {
        case 'SPOUSE':
          edgeColor = Colors.pink.shade300;
          isDashed = true;
          break;
        case 'PARENT':
        case 'CHILD':
        default:
          edgeColor = AppTheme.primary.withValues(alpha: 0.5);
      }

      final paint = Paint()
        ..color = edgeColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (isDashed) {
        _drawDashedLine(canvas, from.position, to.position, paint);
      } else {
        // Ligne courbée
        final path = Path();
        path.moveTo(from.position.dx, from.position.dy);
        final mid = Offset(
          (from.position.dx + to.position.dx) / 2,
          (from.position.dy + to.position.dy) / 2,
        );
        path.quadraticBezierTo(
          from.position.dx, mid.dy,
          to.position.dx, to.position.dy,
        );
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final distance = (to - from).distance;
    double drawn = 0;
    while (drawn < distance) {
      final t1 = drawn / distance;
      final t2 = ((drawn + dashWidth) / distance).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(from.dx + dx * t1, from.dy + dy * t1),
        Offset(from.dx + dx * t2, from.dy + dy * t2),
        paint,
      );
      drawn += dashWidth + dashSpace;
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final node in nodes) {
      final isSelected = node.id == selectedId;
      final center = node.position;
      const r = TreeLayout.nodeRadius;

      // Ombre
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center + const Offset(2, 3), r, shadowPaint);

      // Cercle fond
      final bgColor = node.isDeceased
          ? Colors.grey.shade300
          : isSelected
              ? AppTheme.primary
              : Colors.white;
      canvas.drawCircle(center, r, Paint()..color = bgColor);

      // Bordure
      final borderColor = isSelected
          ? AppTheme.primary
          : node.hasLinkedProfile
              ? AppTheme.primary.withValues(alpha: 0.7)
              : Colors.grey.shade300;
      canvas.drawCircle(
        center, r,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3 : 2,
      );

      // Badge genre
      if (node.gender != null) {
        final genderColor = node.gender == 'MALE' ? Colors.blue.shade300 : Colors.pink.shade300;
        canvas.drawCircle(
          center + Offset(r * 0.7, -r * 0.7),
          8,
          Paint()..color = genderColor,
        );
      }

      // Initiale
      final textColor = isSelected ? Colors.white : AppTheme.primary;
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.initial,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      // Nom sous le nœud
      final namePainter = TextPainter(
        text: TextSpan(
          text: node.displayName,
          style: TextStyle(
            color: node.isDeceased ? Colors.grey : Colors.black87,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 100);
      namePainter.paint(
        canvas,
        center + Offset(-namePainter.width / 2, r + 6),
      );

      // Croix si décédé
      if (node.isDeceased) {
        final crossPainter = TextPainter(
          text: const TextSpan(
            text: '†',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        crossPainter.paint(canvas, center + Offset(-crossPainter.width / 2, r + 32));
      }
    }
  }

  @override
  bool shouldRepaint(FamilyTreePainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.edges != edges ||
      oldDelegate.selectedId != selectedId;

  /// Hit test : retourne l'id du nœud cliqué
  String? findNodeAt(Offset point) {
    for (final node in nodes) {
      if ((node.position - point).distance <= TreeLayout.nodeRadius + 10) {
        return node.id;
      }
    }
    return null;
  }
}

// ── Widget principal ──────────────────────────────────────────────────────────

class FamilyTreeCanvas extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> relationships;
  final void Function(Map<String, dynamic> member)? onMemberTap;

  const FamilyTreeCanvas({
    super.key,
    required this.members,
    required this.relationships,
    this.onMemberTap,
  });

  @override
  State<FamilyTreeCanvas> createState() => _FamilyTreeCanvasState();
}

class _FamilyTreeCanvasState extends State<FamilyTreeCanvas> {
  late List<TreeNode> _nodes;
  late List<TreeEdge> _edges;
  late Size _canvasSize;
  String? _selectedId;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _buildGraph();
  }

  @override
  void didUpdateWidget(FamilyTreeCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) _buildGraph();
  }

  void _buildGraph() {
    // Construire les nœuds
    _nodes = widget.members.map((m) => TreeNode(
      id: m['id'] as String,
      firstName: m['firstName'] as String? ?? '',
      lastName: m['lastName'] as String? ?? '',
      gender: m['gender'] as String?,
      isDeceased: m['isDeceased'] as bool? ?? false,
      hasLinkedProfile: m['hasLinkedProfile'] as bool? ?? false,
    )).toList();

    // Construire les arêtes depuis les relations de chaque membre
    final Set<String> addedEdges = {};
    _edges = [];
    for (final member in widget.members) {
      final relations = member['relations'] as List<dynamic>? ?? [];
      for (final rel in relations) {
        final type = rel['type'] as String? ?? '';
        final fromId = rel['fromMember']?['id'] as String?;
        final toId = rel['toMember']?['id'] as String?;
        if (fromId == null || toId == null) continue;
        final key = '${fromId}_${toId}_$type';
        final keyRev = '${toId}_${fromId}_$type';
        if (!addedEdges.contains(key) && !addedEdges.contains(keyRev)) {
          _edges.add(TreeEdge(fromId: fromId, toId: toId, type: type));
          addedEdges.add(key);
        }
      }
    }

    // Calculer le layout
    TreeLayout.compute(_nodes, _edges);
    _canvasSize = TreeLayout.computeCanvasSize(_nodes);
  }

  void _handleTap(TapDownDetails details) {
    final matrix = _transformController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = Offset(matrix.getTranslation().x, matrix.getTranslation().y);
    final localPoint = (details.localPosition - translation) / scale;

    final painter = FamilyTreePainter(nodes: _nodes, edges: _edges);
    final tappedId = painter.findNodeAt(localPoint);

    if (tappedId != null) {
      setState(() => _selectedId = tappedId == _selectedId ? null : tappedId);
      if (widget.onMemberTap != null) {
        final member = widget.members.firstWhere((m) => m['id'] == tappedId, orElse: () => {});
        if (member.isNotEmpty) widget.onMemberTap!(member);
      }
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: InteractiveViewer(
        transformationController: _transformController,
        minScale: 0.3,
        maxScale: 3.0,
        boundaryMargin: const EdgeInsets.all(200),
        child: SizedBox(
          width: _canvasSize.width,
          height: _canvasSize.height,
          child: CustomPaint(
            size: _canvasSize,
            painter: FamilyTreePainter(
              nodes: _nodes,
              edges: _edges,
              selectedId: _selectedId,
            ),
          ),
        ),
      ),
    );
  }
}
