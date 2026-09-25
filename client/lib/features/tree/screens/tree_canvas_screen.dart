import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/civil_models.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/tree_graph_model.dart';
import '../providers/tree_provider.dart';

class TreeCanvasScreen extends ConsumerStatefulWidget {
  final String rootVuid;
  const TreeCanvasScreen({super.key, required this.rootVuid});

  /// Evaluates node color based on civil status and gender:
  /// - Gray if died (status == 'Deceased')
  /// - Blue for male
  /// - Pink for female
  /// - Purple for other all genders
  static Color getNodeColor(TreeCitizenNode node) {
    final status = node.status.toLowerCase();
    final gender = node.gender.toLowerCase();

    // Priority 1: Gray if died
    if (status == 'deceased') {
      return const Color(0xFF6B7280);
    }
    // Priority 2: Blue for male
    if (gender == 'male') {
      return const Color(0xFF2563EB);
    }
    // Priority 3: Pink for female
    if (gender == 'female') {
      return const Color(0xFFEC4899);
    }
    // Priority 4: Purple for other all genders
    return const Color(0xFFA855F7);
  }

  /// Returns the corresponding bundled avatar portrait asset
  static String getAvatarAsset(TreeCitizenNode node) {
    final status = node.status.toLowerCase();
    final gender = node.gender.toLowerCase();

    if (status == 'deceased') {
      return 'assets/images/deceased_avatar.jpg';
    }
    if (gender == 'male') {
      return 'assets/images/male_avatar.jpg';
    }
    if (gender == 'female') {
      return 'assets/images/female_avatar.jpg';
    }
    return 'assets/images/other_avatar.jpg';
  }

  @override
  ConsumerState<TreeCanvasScreen> createState() => _TreeCanvasScreenState();
}

class _TreeCanvasScreenState extends ConsumerState<TreeCanvasScreen> {
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.translationValues(0.0, 0.0, 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  String _calculateAge(String dobStr) {
    if (dobStr.isEmpty) return '';
    try {
      final dob = DateTime.parse(dobStr);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age >= 0 ? '$age yrs' : '';
    } catch (_) {
      return '';
    }
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
        const SizedBox(width: 8),
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showNodeDetails(TreeCitizenNode node) {
    final ageText = _calculateAge(node.dob);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: TreeCanvasScreen.getNodeColor(node), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: TreeCanvasScreen.getNodeColor(node), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: TreeCanvasScreen.getNodeColor(node).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        TreeCanvasScreen.getAvatarAsset(node),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          node.status.toLowerCase() == 'deceased'
                              ? Icons.person_off_outlined
                              : Icons.person,
                          color: TreeCanvasScreen.getNodeColor(node),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'VUID: ${node.formattedVuid}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (node.isVerified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          child: const Text(
                            'VERIFIED',
                            style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (node.isClaimed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          child: const Text(
                            'CLAIMED',
                            style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Member Full Details Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.person_outline,
                      label: 'Gender & Status',
                      value: '${node.gender} • ${node.status}',
                    ),
                    const Divider(height: 12, color: Colors.white10),
                    _buildDetailRow(
                      icon: Icons.cake_outlined,
                      label: 'DOB / Age',
                      value: '${node.dob}${ageText.isNotEmpty ? ' ($ageText)' : ''}',
                    ),
                    const Divider(height: 12, color: Colors.white10),
                    _buildDetailRow(
                      icon: Icons.groups_outlined,
                      label: 'Gotra & Caste',
                      value: '${node.gotra} • ${node.caste} (${node.category})',
                    ),
                    const Divider(height: 12, color: Colors.white10),
                    _buildDetailRow(
                      icon: Icons.auto_awesome_outlined,
                      label: 'Religion',
                      value: node.religion,
                    ),
                    const Divider(height: 12, color: Colors.white10),
                    _buildDetailRow(
                      icon: Icons.favorite_border,
                      label: 'Marital & Blood Group',
                      value: '${node.maritalStatus} • Blood: ${node.bloodGroup}',
                    ),
                    const Divider(height: 12, color: Colors.white10),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Residence',
                      value: '${node.district}, ${node.state}',
                    ),
                  ],
                ),
              ),

              const Divider(height: 24, color: Colors.white12),

            const Text(
              'LEAF ACTIONS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddKinDialog(node);
                    },
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Kin'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showModifyNodeDialog(node);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modify'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmDeleteNode(node);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  foregroundColor: const Color(0xFF38BDF8),
                ),
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
                icon: const Icon(Icons.credit_card, size: 18),
                label: const Text('View Vansha Card Credential'),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'LIFE EVENTS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.1),
            ),
            const SizedBox(height: 8),
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
                    avatar: const Icon(Icons.family_restroom, size: 16, color: Color(0xFF10B981)),
                    label: const Text('Adopt Child'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAdoptionDialog(node);
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
          ],
        ),
      ),
      ),
    );
  }

  void _confirmDeleteNode(TreeCitizenNode node) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leaf Node'),
        content: Text('Are you sure you want to remove ${node.name} (${node.formattedVuid}) from the lineage canvas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(treeProvider.notifier).removeNode(node.vuid);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed ${node.name} from tree canvas.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showModifyNodeDialog(TreeCitizenNode node) {
    final nameController = TextEditingController(text: node.name);
    final dobController = TextEditingController(text: node.dob);
    String gender = node.gender;
    String category = node.category;
    String status = node.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Modify Leaf: ${node.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: 'DOB (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: CivilGenders.all.contains(gender) ? gender : 'Male',
                  items: CivilGenders.all
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => gender = v!),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: CivilCategories.all.contains(category) ? category : 'GEN',
                  items: CivilCategories.all
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active (Living)')),
                    DropdownMenuItem(value: 'Deceased', child: Text('Deceased')),
                  ],
                  onChanged: (v) => setDialogState(() => status = v!),
                  decoration: const InputDecoration(labelText: 'Civil Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = TreeCitizenNode(
                  vuid: node.vuid,
                  formattedVuid: node.formattedVuid,
                  name: nameController.text.trim(),
                  gender: gender,
                  dob: dobController.text.trim(),
                  category: category,
                  isVerified: node.isVerified,
                  isClaimed: node.isClaimed,
                  status: status,
                  position: node.position,
                );
                Navigator.pop(ctx);
                ref.read(treeProvider.notifier).updateNode(updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated ${updated.name} details.')),
                );
              },
              child: const Text('Save Changes'),
            ),
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
                isExpanded: true,
                initialValue: relationship,
                items: CivilRelationships.all
                    .take(30)
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            '${CivilRelationships.getLocalizedLabel(r, ref.read(localeProvider).languageCode)} ($r)',
                            overflow: TextOverflow.ellipsis,
                          ),
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

  void _showAdoptionDialog(TreeCitizenNode parentNode) {
    final nameController = TextEditingController();
    String childGender = 'Male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Adopt Child — ${parentNode.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Adopted Child First Name', hintText: 'Aarav'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
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
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(ctx);
                  final client = ref.read(apiClientProvider);
                  final regRes = await client.post(
                    ApiEndpoints.citizenRegister,
                    body: {
                      'first_name': nameController.text.trim(),
                      'last_name': parentNode.name.split(' ').last,
                      'gender': childGender,
                      'dob': DateTime.now().toIso8601String().split('T').first,
                      'pin_code': '452001',
                      'district': 'Indore',
                      'state': 'Madhya Pradesh',
                    },
                  );
                  final newVuid = regRes['vuid'] ?? regRes['data']?['vuid'];
                  if (newVuid != null) {
                    final relationshipType = childGender == 'Male'
                        ? 'Adopted_Son'
                        : (childGender == 'Female' ? 'Adopted_Daughter' : 'Adopted_Child');
                    await ref.read(treeProvider.notifier).connectKinship(
                      sourceVuid: parentNode.vuid,
                      targetVuid: newVuid.toString(),
                      relationshipType: relationshipType,
                    );
                  } else {
                    ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adopted child registered and linked!')));
                  }
                }
              },
              child: const Text('Record Adoption'),
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

  bool _hasAutoCentered = false;
  double _lastViewportWidth = 1200.0;
  double _lastViewportHeight = 800.0;

  void _centerAndFitCanvas(double viewportWidth, double viewportHeight) {
    _lastViewportWidth = viewportWidth;
    _lastViewportHeight = viewportHeight;

    final graph = ref.read(treeProvider).graphData;
    if (graph == null || graph.nodes.isEmpty) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    const double cardWidth = 170.0;
    const double cardHeight = 180.0;
    const double margin = 40.0;

    final double minX = graph.nodes.map((n) => n.position.dx).reduce(min);
    final double maxX = graph.nodes.map((n) => n.position.dx).reduce(max);
    final double minY = graph.nodes.map((n) => n.position.dy).reduce(min);
    final double maxY = graph.nodes.map((n) => n.position.dy).reduce(max);

    final double treeWidth = (maxX - minX) + cardWidth;
    final double treeHeight = (maxY - minY) + cardHeight;

    final double availW = max(300.0, viewportWidth - margin * 2);
    final double availH = max(300.0, viewportHeight - margin * 2);

    double scale = min(availW / treeWidth, availH / treeHeight);
    scale = scale.clamp(0.25, 1.0);

    final double scaledW = treeWidth * scale;
    final double scaledH = treeHeight * scale;

    final double tx = (viewportWidth - scaledW) / 2 - (minX * scale);
    final double ty = max(20.0, (viewportHeight - scaledH) / 2 - (minY * scale));

    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty, 0.0)
      ..scale(scale);
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
            tooltip: 'Center & Fit Canvas',
            onPressed: () => _centerAndFitCanvas(_lastViewportWidth, _lastViewportHeight),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Lineage',
            onPressed: () {
              _hasAutoCentered = false;
              ref.read(treeProvider.notifier).fetchTree(widget.rootVuid);
            },
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
                value: '/registration',
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 10),
                    Text('New Citizen Registration'),
                  ],
                ),
              ),
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    _lastViewportWidth = constraints.maxWidth;
                    _lastViewportHeight = constraints.maxHeight;

                    double canvasW = 3200.0;
                    double canvasH = 2600.0;
                    if (treeState.graphData != null && treeState.graphData!.nodes.isNotEmpty) {
                      for (final n in treeState.graphData!.nodes) {
                        if (n.position.dx + 450.0 > canvasW) canvasW = n.position.dx + 450.0;
                        if (n.position.dy + 450.0 > canvasH) canvasH = n.position.dy + 450.0;
                      }
                    }

                    if (!_hasAutoCentered && treeState.graphData != null) {
                      _hasAutoCentered = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _centerAndFitCanvas(constraints.maxWidth, constraints.maxHeight);
                      });
                    }

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      clipBehavior: Clip.none,
                      minScale: 0.05,
                      maxScale: 5.0,
                      child: SizedBox(
                        width: canvasW,
                        height: canvasH,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (treeState.graphData != null)
                              CustomPaint(
                                size: Size(canvasW, canvasH),
                                painter: KinshipLinePainter(
                                  nodes: treeState.graphData!.nodes,
                                  edges: treeState.graphData!.edges,
                                ),
                              ),
                            if (treeState.graphData != null)
                              ...treeState.graphData!.nodes.map((node) => Positioned(
                                left: node.position.dx,
                                top: node.position.dy,
                                child: _NodeTapWrapper(
                                  onTap: () => _showNodeDetails(node),
                                  child: _buildNodeCard(node),
                                ),
                              )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildNodeCard(TreeCitizenNode node) {
    final nodeColor = TreeCanvasScreen.getNodeColor(node);
    final avatarAsset = TreeCanvasScreen.getAvatarAsset(node);
    final isRoot = node.vuid == widget.rootVuid;
    final isDeceased = node.status.toLowerCase() == 'deceased';
    final ageText = _calculateAge(node.dob);

    return SizedBox(
      width: 170,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Round Leaf Node with Image & Gender/Status Border
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.12),
                  border: Border.all(
                    color: nodeColor,
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: nodeColor.withOpacity(0.35),
                      blurRadius: 10,
                      spreadRadius: 1.5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    avatarAsset,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: nodeColor.withOpacity(0.15),
                      child: Icon(
                        isDeceased
                            ? Icons.person_off_outlined
                            : (node.gender.toLowerCase() == 'male'
                                ? Icons.face
                                : (node.gender.toLowerCase() == 'female'
                                    ? Icons.face_3
                                    : Icons.person)),
                        size: 32,
                        color: nodeColor,
                      ),
                    ),
                  ),
                ),
              ),
              // Root Indicator Crown/Star Badge
              if (isRoot)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.star, size: 12, color: Colors.white),
                  ),
                ),
              // Deceased Ribbon Badge
              if (isDeceased)
                Positioned(
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF9CA3AF), width: 1),
                    ),
                    child: const Text(
                      'DECEASED',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5E7EB),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // 2. Below Round Image: Details in Rectangle (Name & Age Only)
          Container(
            width: 170,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isRoot ? const Color(0xFFF59E0B) : nodeColor.withOpacity(0.5),
                width: isRoot ? 2.0 : 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        node.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (node.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Colors.greenAccent),
                    ],
                  ],
                ),
                if (ageText.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    ageText,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
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
    const double cardWidth = 170.0;
    const double cardHeight = 124.0; // Bottom mid border of details box (68px avatar + 6px gap + ~50px details box)

    final mainLinePaint = Paint()
      ..color = const Color(0xFF38BDF8) // Vibrant cyan/sky blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final unverifiedLinePaint = Paint()
      ..color = const Color(0xFFF59E0B) // Amber warning color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spouseLinePaint = Paint()
      ..color = const Color(0xFFEC4899) // Hot pink / Rose
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final nodeMap = {for (var n in nodes) n.vuid: n};

    // 1. Process Unique Spouse Pairs
    final processedSpouses = <String>{};
    for (final edge in edges) {
      if (edge.type == 'Spouse') {
        final source = nodeMap[edge.source];
        final target = nodeMap[edge.target];
        if (source == null || target == null) continue;

        final pairKey = [source.vuid, target.vuid]..sort();
        final pairId = pairKey.join('-');
        if (processedSpouses.contains(pairId)) continue;
        processedSpouses.add(pairId);

        // Determine left and right spouse
        final left = source.position.dx < target.position.dx ? source : target;
        final right = source.position.dx < target.position.dx ? target : source;

        final startX = left.position.dx + cardWidth;
        final endX = right.position.dx;
        final y = left.position.dy + 34.0; // vertical center of 68px node avatar

        // Draw spouse connector line
        canvas.drawLine(Offset(startX, y), Offset(endX, y), spouseLinePaint);

        // Draw Marriage Badge (⚭) in the middle of spouse line
        final midX = (startX + endX) / 2;
        final badgeRect = RRect.fromLTRBR(
          midX - 11, y - 9, midX + 11, y + 9, const Radius.circular(9)
        );

        final badgeBgPaint = Paint()
          ..color = const Color(0xFF1E1B4B)
          ..style = PaintingStyle.fill;
        final badgeBorderPaint = Paint()
          ..color = const Color(0xFFEC4899)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawRRect(badgeRect, badgeBgPaint);
        canvas.drawRRect(badgeRect, badgeBorderPaint);

        final textPainter = TextPainter(
          text: const TextSpan(
            text: '⚭',
            style: TextStyle(color: Color(0xFFF472B6), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(midX - textPainter.width / 2, y - textPainter.height / 2));
      }
    }

    // 2. Process Individual Parent-to-Child & Adoption Lineage Connections (Color matches starting parent node)
    final childToParents = <String, Set<String>>{};
    for (final edge in edges) {
      final isParentEdge = edge.type == 'Father' ||
          edge.type == 'Mother' ||
          edge.type == 'Guardian' ||
          edge.type.contains('Adopt');

      if (isParentEdge) {
        childToParents.putIfAbsent(edge.target, () => {}).add(edge.source);

        final parentNode = nodeMap[edge.source];
        final childNode = nodeMap[edge.target];
        if (parentNode == null || childNode == null) continue;

        // Starting parent node color dictates arrow line & arrow head color!
        final parentColor = TreeCanvasScreen.getNodeColor(parentNode);

        final linePaint = Paint()
          ..color = parentColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        // Origin at bottom-center of parent card details box
        final parentOrigin = Offset(
          parentNode.position.dx + cardWidth / 2,
          parentNode.position.dy + cardHeight,
        );

        // Target top-center of child card
        final isFather = edge.type == 'Father' || parentNode.gender.toLowerCase() == 'male';
        final offsetShift = isFather ? -12.0 : 12.0;
        final childTarget = Offset(
          childNode.position.dx + cardWidth / 2 + offsetShift,
          childNode.position.dy,
        );

        // Drop 12px straight down from box bottom mid border to clear container border & drop shadow cleanly
        final routedDropPoint = Offset(parentOrigin.dx, parentOrigin.dy + 12.0);
        canvas.drawLine(parentOrigin, routedDropPoint, linePaint);

        final isAdopted = edge.type.contains('Adopt') || edge.status == 'Adopted';

        if (isAdopted) {
          // Draw dashed inclined line for adoption
          const dashWidth = 8.0;
          const dashGap = 5.0;
          final dx = childTarget.dx - routedDropPoint.dx;
          final dy = childTarget.dy - routedDropPoint.dy;
          final distance = sqrt(dx * dx + dy * dy);
          final unitX = distance > 0 ? dx / distance : 0.0;
          final unitY = distance > 0 ? dy / distance : 0.0;

          double drawn = 0.0;
          while (drawn < distance) {
            final startDist = drawn;
            final endDist = min(drawn + dashWidth, distance);
            canvas.drawLine(
              Offset(routedDropPoint.dx + unitX * startDist, routedDropPoint.dy + unitY * startDist),
              Offset(routedDropPoint.dx + unitX * endDist, routedDropPoint.dy + unitY * endDist),
              linePaint,
            );
            drawn += dashWidth + dashGap;
          }

          // Draw "Adopted" / "दत्तक" Pill Badge on midpoint of adoption arrow
          final midX = (routedDropPoint.dx + childTarget.dx) / 2;
          final midY = (routedDropPoint.dy + childTarget.dy) / 2;
          final badgeRect = RRect.fromLTRBR(
            midX - 24, midY - 9, midX + 24, midY + 9, const Radius.circular(9)
          );

          final badgeBgPaint = Paint()
            ..color = const Color(0xFF064E3B) // Dark Emerald Green
            ..style = PaintingStyle.fill;
          final badgeBorderPaint = Paint()
            ..color = const Color(0xFF10B981) // Emerald Green Accent
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke;

          canvas.drawRRect(badgeRect, badgeBgPaint);
          canvas.drawRRect(badgeRect, badgeBorderPaint);

          final badgeTextPainter = TextPainter(
            text: const TextSpan(
              text: 'Adopted',
              style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 9.5, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          );
          badgeTextPainter.layout();
          badgeTextPainter.paint(
            canvas,
            Offset(midX - badgeTextPainter.width / 2, midY - badgeTextPainter.height / 2),
          );
        } else {
          // Draw solid inclined line from routedDropPoint to childTarget
          canvas.drawLine(routedDropPoint, childTarget, linePaint);
        }

        // Draw Arrow Head matching starting parent node color!
        _drawArrowHead(canvas, routedDropPoint, childTarget, parentColor);
      }
    }

    // 3. Process Non-Parental Sibling Links
    for (final edge in edges) {
      if (edge.type == 'Sibling') {
        final source = nodeMap[edge.source];
        final target = nodeMap[edge.target];
        if (source == null || target == null) continue;

        final sourceHasParents = childToParents.containsKey(source.vuid);
        final targetHasParents = childToParents.containsKey(target.vuid);
        if (!sourceHasParents || !targetHasParents) {
          final startX = source.position.dx + cardWidth;
          final endX = target.position.dx;
          final y = source.position.dy + 34.0; // vertical center of 68px node avatar

          final edgePaint = edge.status == 'Unverified' ? unverifiedLinePaint : mainLinePaint;

          // Draw dashed horizontal line for sibling connection
          const dashWidth = 6.0;
          const dashGap = 4.0;
          double x = startX;
          while (x < endX) {
            canvas.drawLine(
              Offset(x, y),
              Offset((x + dashWidth).clamp(startX, endX), y),
              edgePaint,
            );
            x += dashWidth + dashGap;
          }
        }
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Color color) {
    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 10.0;
    final arrowAngle = pi / 6;

    final path = Path();
    path.moveTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * cos(angle - arrowAngle),
      to.dy - arrowSize * sin(angle - arrowAngle),
    );
    path.lineTo(
      to.dx - arrowSize * cos(angle + arrowAngle),
      to.dy - arrowSize * sin(angle + arrowAngle),
    );
    path.close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant KinshipLinePainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.edges != edges;
  }
}

class _NodeTapWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _NodeTapWrapper({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  State<_NodeTapWrapper> createState() => _NodeTapWrapperState();
}

class _NodeTapWrapperState extends State<_NodeTapWrapper> {
  Offset? _downLocalPos;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _downLocalPos = event.localPosition;
      },
      onPointerUp: (event) {
        if (_downLocalPos != null) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final size = renderBox.size;
            final localUp = renderBox.globalToLocal(event.position);
            if (localUp.dx >= 0 &&
                localUp.dx <= size.width &&
                localUp.dy >= 0 &&
                localUp.dy <= size.height) {
              final dist = (localUp - _downLocalPos!).distance;
              if (dist < 15.0) {
                widget.onTap();
              }
            }
          }
        }
      },
      child: widget.child,
    );
  }
}
