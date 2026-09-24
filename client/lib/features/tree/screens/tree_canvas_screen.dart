import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/civil_models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
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

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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
            const Divider(height: 24),
            // Life Events Action Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.school, size: 16, color: Color(0xFF38BDF8)),
                    label: const Text('Education'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showEducationDialog(node);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.child_friendly, size: 16, color: Colors.greenAccent),
                    label: const Text('Add Child'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showBirthDialog(node);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.favorite, size: 16, color: Color(0xFFF472B6)),
                    label: const Text('Marriage'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showMarriageDialog(node);
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.sentiment_dissatisfied, size: 16, color: Colors.purpleAccent),
                    label: const Text('Record Death'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDeathDialog(node);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                items: CivilRelationships.all
                    .take(30)
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text('${CivilRelationships.getLocalizedLabel(r, ref.read(localeProvider).languageCode)} ($r)'),
                        ))
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
    ).then((_) {
      vuidController.dispose();
    });
  }

  void _showEducationDialog(TreeCitizenNode node) {
    final degreeController = TextEditingController();
    final instController = TextEditingController();
    String qualification = 'Bachelors';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Education & Career — ${node.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: qualification,
              items: ['Primary', 'Secondary_10th', 'HigherSecondary_12th', 'Diploma', 'Bachelors', 'Masters', 'Doctorate']
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (v) => qualification = v!,
              decoration: const InputDecoration(labelText: 'Highest Qualification'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Degree / Specialization', hintText: 'B.Tech / MBA / MBBS'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instController,
              decoration: const InputDecoration(labelText: 'University / Institution', hintText: 'IIT Bombay / AIIMS'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (degreeController.text.isNotEmpty && instController.text.isNotEmpty) {
                Navigator.pop(ctx);
                final client = ref.read(apiClientProvider);
                await client.post(
                  ApiEndpoints.educationAdd,
                  body: {
                    'vuid': node.vuid,
                    'qualification_level': qualification,
                    'degree_name': degreeController.text.trim(),
                    'institution': instController.text.trim(),
                    'year_of_passing': 2024
                  },
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Education details recorded successfully!')));
                }
              }
            },
            child: const Text('Save Qualification'),
          ),
        ],
      ),
    ).then((_) {
      degreeController.dispose();
      instController.dispose();
    });
  }

  void _showBirthDialog(TreeCitizenNode parentNode) {
    final nameController = TextEditingController();
    String childGender = 'Male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Register Child of ${parentNode.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Child First Name', hintText: 'Aaradhya'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: childGender,
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setDialogState(() => childGender = v!),
                decoration: const InputDecoration(labelText: 'Child Gender'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(ctx);
                  final client = ref.read(apiClientProvider);
                  await client.post(
                    ApiEndpoints.eventBirth,
                    body: {
                      parentNode.gender == 'Male' ? 'father_vuid' : 'mother_vuid': parentNode.vuid,
                      'first_name': nameController.text.trim(),
                      'last_name': parentNode.name.split(' ').last,
                      'gender': childGender,
                      'dob': DateTime.now().toIso8601String().split('T').first,
                    },
                  );
                  ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child birth registered with new 12-Digit VUID!')));
                  }
                }
              },
              child: const Text('Register Birth'),
            ),
          ],
        ),
      ),
    ).then((_) => nameController.dispose());
  }

  void _showMarriageDialog(TreeCitizenNode node) {
    final spouseVuidController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Register Marriage — ${node.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: spouseVuidController,
              decoration: const InputDecoration(labelText: 'Spouse 12-Digit VUID', hintText: '710293849103'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final spouseVuid = spouseVuidController.text.trim();
              if (spouseVuid.length == 12) {
                Navigator.pop(ctx);
                final client = ref.read(apiClientProvider);
                await client.post(
                  ApiEndpoints.eventMarriage,
                  body: {
                    node.gender == 'Male' ? 'groom_vuid' : 'bride_vuid': node.vuid,
                    node.gender == 'Male' ? 'bride_vuid' : 'groom_vuid': spouseVuid,
                    'marriage_date': DateTime.now().toIso8601String().split('T').first,
                  },
                );
                ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marriage registered and mutual spouse edge created!')));
                }
              }
            },
            child: const Text('Record Marriage'),
          ),
        ],
      ),
    ).then((_) => spouseVuidController.dispose());
  }

  void _showDeathDialog(TreeCitizenNode node) {
    final reasonController = TextEditingController(text: 'Natural');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Record Death Certificate — ${node.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Cause / Medical Details', hintText: 'Natural / Old Age'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final client = ref.read(apiClientProvider);
              await client.post(
                ApiEndpoints.eventDeath,
                body: {
                  'vuid': node.vuid,
                  'death_date': DateTime.now().toIso8601String().split('T').first,
                  'death_reason': reasonController.text.trim(),
                },
              );
              ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Citizen transitioned to Deceased status in civil registry.')));
              }
            },
            child: const Text('Confirm Deceased'),
          ),
        ],
      ),
    ).then((_) => reasonController.dispose());
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
          const LanguageSelectorButton(),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Sovereign DPI Hub',
            onSelected: (val) {
              Navigator.pushNamed(context, val);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: '/demographics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Color(0xFF38BDF8), size: 20),
                    SizedBox(width: 10),
                    Text('National Demographics'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/matrimony',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Color(0xFFF472B6), size: 20),
                    SizedBox(width: 10),
                    Text('Matrimony Hub (Gotra Exogamy)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: '/audit',
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.greenAccent, size: 20),
                    SizedBox(width: 10),
                    Text('HIPAA § 164.312 Audit Trail'),
                  ],
                ),
              ),
            ],
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
  bool shouldRepaint(covariant KinshipLinePainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.edges != edges;
  }
}
