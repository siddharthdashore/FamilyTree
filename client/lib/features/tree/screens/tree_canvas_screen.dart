import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tree_graph_model.dart';
import '../providers/tree_provider.dart';

class TreeCanvasScreen extends ConsumerStatefulWidget {
  final String rootVuid;
  const TreeCanvasScreen({super.key, required this.rootVuid});

  @override
  ConsumerState<TreeCanvasScreen> createState() => _TreeCanvasScreenState();
}

class _TreeCanvasScreenState extends ConsumerState<TreeCanvasScreen> {
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.translationValues(-300.0, -250.0, 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
    });
  }

  void _showNodeDetails(TreeCitizenNode node) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    node.name,
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (node.isVerified)
                  const Chip(
                    label: Text('OCP VERIFIED', style: TextStyle(fontSize: 10, color: Colors.green)),
                    backgroundColor: Color(0xFFE8F5E9),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'VUID: ${node.formattedVuid}',
              style: const TextStyle(fontFamily: 'monospace', color: Colors.blueGrey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Gender: ${node.gender} • Category: ${node.category} • Status: ${node.status}'),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/card', arguments: {
                        'vuid': node.vuid,
                        'fullName': node.name,
                        'dob': node.dob,
                        'gender': node.gender,
                        'category': node.category,
                        'state': 'India',
                      });
                    },
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Vansha Card'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddKinDialog(node);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Kin'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddKinDialog(TreeCitizenNode sourceNode) {
    final vuidController = TextEditingController();
    String relationship = 'Son';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Connect Kin to ${sourceNode.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vuidController,
                decoration: const InputDecoration(
                  labelText: 'Relative 12-Digit VUID',
                  hintText: '510928340192',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: relationship,
                items: ['Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Sibling', 'Guardian']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setDialogState(() => relationship = v!),
                decoration: const InputDecoration(labelText: 'Relationship'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final targetVuid = vuidController.text.trim();
                if (targetVuid.length == 12) {
                  Navigator.pop(ctx);
                  await ref.read(treeProvider.notifier).connectKinship(
                    sourceVuid: sourceNode.vuid,
                    targetVuid: targetVuid,
                    relationshipType: relationship,
                  );
                }
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treeState = ref.watch(treeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VanshaSetu Lineage Canvas', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Center Canvas',
            onPressed: () => _transformationController.value = Matrix4.translationValues(-300.0, -250.0, 0.0),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Lineage',
            onPressed: () => ref.read(treeProvider.notifier).fetchTree(widget.rootVuid),
          ),
        ],
      ),
      body: treeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : treeState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(treeState.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.read(treeProvider.notifier).fetchTree(widget.rootVuid),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(1000),
                  minScale: 0.2,
                  maxScale: 2.5,
                  child: SizedBox(
                    width: 2000,
                    height: 2000,
                    child: Stack(
                      children: [
                        if (treeState.graphData != null)
                          CustomPaint(
                            size: const Size(2000, 2000),
                            painter: KinshipLinePainter(
                              nodes: treeState.graphData!.nodes,
                              edges: treeState.graphData!.edges,
                            ),
                          ),
                        if (treeState.graphData != null)
                          ...treeState.graphData!.nodes.map((node) => Positioned(
                            left: node.position.dx,
                            top: node.position.dy,
                            child: GestureDetector(
                              onTap: () => _showNodeDetails(node),
                              child: _buildNodeCard(node),
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNodeCard(TreeCitizenNode node) {
    final isMale = node.gender == 'Male';
    final isRoot = node.vuid == widget.rootVuid;

    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRoot
              ? const Color(0xFF38BDF8)
              : (isMale ? const Color(0xFF1E3A8A) : const Color(0xFFBE185D)),
          width: isRoot ? 2.5 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  node.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (node.isVerified)
                const Icon(Icons.verified, size: 14, color: Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            node.gender,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            node.formattedVuid,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class KinshipLinePainter extends CustomPainter {
  final List<TreeCitizenNode> nodes;
  final List<KinshipEdge> edges;

  KinshipLinePainter({required this.nodes, required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final parentPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final spousePaint = Paint()
      ..color = const Color(0xFF9333EA)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final nodeMap = {for (var n in nodes) n.vuid: n};

    for (final edge in edges) {
      final source = nodeMap[edge.source];
      final target = nodeMap[edge.target];
      if (source == null || target == null) continue;

      if (edge.type == 'Spouse') {
        // Horizontal connecting line between spouses
        canvas.drawLine(
          Offset(source.position.dx + 170, source.position.dy + 42),
          Offset(target.position.dx, target.position.dy + 42),
          spousePaint,
        );
      } else {
        // Smooth cubic Bezier from parent down to child
        final path = Path();
        final startX = source.position.dx + 85;
        final startY = source.position.dy + 85;
        final endX = target.position.dx + 85;
        final endY = target.position.dy;

        path.moveTo(startX, startY);
        path.cubicTo(
          startX,
          startY + (endY - startY) * 0.5,
          endX,
          startY + (endY - startY) * 0.5,
          endX,
          endY,
        );
        canvas.drawPath(path, parentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
