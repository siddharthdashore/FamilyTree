import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/tree_graph_model.dart';

class TreeState {
  final bool isLoading;
  final String? errorMessage;
  final TreeGraphData? graphData;

  const TreeState({
    this.isLoading = false,
    this.errorMessage,
    this.graphData,
  });

  TreeState copyWith({
    bool? isLoading,
    String? errorMessage,
    TreeGraphData? graphData,
  }) {
    return TreeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      graphData: graphData ?? this.graphData,
    );
  }
}

class TreeNotifier extends StateNotifier<TreeState> {
  final Ref _ref;

  TreeNotifier(this._ref) : super(const TreeState());

  static TreeGraphData createDatabaseSeedGraph() {
    final nodes = [
      // Gen 1: Paternal Grandparents
      TreeCitizenNode(vuid: '109284729102', formattedVuid: '1092 8472 9102', name: 'Kailash Prasad Sharma', gender: 'Male', dob: '1948-03-12', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'O+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '109284729103', formattedVuid: '1092 8472 9103', name: 'Savitri Devi Sharma', gender: 'Female', dob: '1950-06-18', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'A+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      // Gen 2: Children of Kailash & Savitri (3 Couples)
      TreeCitizenNode(vuid: '510928340192', formattedVuid: '5109 2834 0192', name: 'Ramesh Chandra Sharma', gender: 'Male', dob: '1972-07-24', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'B+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '510928340193', formattedVuid: '5109 2834 0193', name: 'Sunita Sharma', gender: 'Female', dob: '1975-11-05', caste: 'Brahmin', category: 'GEN', gotra: 'Kashyap', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'A+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      
      TreeCitizenNode(vuid: '391029485710', formattedVuid: '3910 2948 5710', name: 'Deepak Kumar Sharma', gender: 'Male', dob: '1976-02-14', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'O-', district: 'Indore', state: 'Madhya Pradesh', isVerified: false, isClaimed: false, status: 'Missing'),
      TreeCitizenNode(vuid: '391029485711', formattedVuid: '3910 2948 5711', name: 'Meena Sharma', gender: 'Female', dob: '1978-04-10', caste: 'Brahmin', category: 'GEN', gotra: 'Gautam', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'B+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      TreeCitizenNode(vuid: '510928340194', formattedVuid: '5109 2834 0194', name: 'Vikram Sharma', gender: 'Male', dob: '1980-09-12', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'AB+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '510928340195', formattedVuid: '5109 2834 0195', name: 'Anita Sharma', gender: 'Female', dob: '1982-12-01', caste: 'Brahmin', category: 'GEN', gotra: 'Vashishta', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'O+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      // Gen 3: Children of Ramesh & Sunita (3 Kids: Aarav, Ananya, Ishaan + Spouses)
      TreeCitizenNode(vuid: '284910293847', formattedVuid: '2849 1029 3847', name: 'Aarav Sharma', gender: 'Male', dob: '1998-05-18', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'B+', district: 'Bengaluru Urban', state: 'Karnataka', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '928174019284', formattedVuid: '9281 7401 9284', name: 'Pooja Kumari Sharma', gender: 'Female', dob: '2000-09-22', caste: 'Brahmin', category: 'GEN', gotra: 'Vashishta', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'AB+', district: 'Bengaluru Urban', state: 'Karnataka', isVerified: true, isClaimed: true, status: 'Active'),

      TreeCitizenNode(vuid: '710293849103', formattedVuid: '7102 9384 9103', name: 'Ananya Sharma', gender: 'Female', dob: '2001-08-14', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'A+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '710293849102', formattedVuid: '7102 9384 9102', name: 'Rohan Verma', gender: 'Male', dob: '1996-04-10', caste: 'Kshatriya', category: 'GEN', gotra: 'Vatsa', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'O+', district: 'Ujjain', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      TreeCitizenNode(vuid: '284910293849', formattedVuid: '2849 1029 3849', name: 'Ishaan Sharma', gender: 'Male', dob: '2004-03-30', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'B+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '710293849104', formattedVuid: '7102 9384 9104', name: 'Priya Patel', gender: 'Female', dob: '1997-12-02', caste: 'Kurmi', category: 'OBC', gotra: 'Kashyap', religion: 'Hindu', maritalStatus: 'Married', bloodGroup: 'AB-', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      // Gen 3: Children of Deepak & Meena (2 Cousins: Priyanshu & Riya)
      TreeCitizenNode(vuid: '391029485712', formattedVuid: '3910 2948 5712', name: 'Priyanshu Sharma', gender: 'Male', dob: '2002-01-20', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'O+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '391029485713', formattedVuid: '3910 2948 5713', name: 'Riya Sharma', gender: 'Female', dob: '2005-11-15', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'A+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      // Gen 3: Children of Vikram & Anita (2 Cousins: Kabir & Diya)
      TreeCitizenNode(vuid: '510928340196', formattedVuid: '5109 2834 0196', name: 'Kabir Sharma', gender: 'Male', dob: '2006-07-04', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'B+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '510928340197', formattedVuid: '5109 2834 0197', name: 'Diya Sharma', gender: 'Female', dob: '2008-05-22', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'O+', district: 'Indore', state: 'Madhya Pradesh', isVerified: true, isClaimed: true, status: 'Active'),

      // Gen 4: Children of Aarav & Pooja (2 Kids: Vihaan & Advait)
      TreeCitizenNode(vuid: '819204918274', formattedVuid: '8192 0491 8274', name: 'Vihaan Sharma', gender: 'Male', dob: '2024-01-15', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'B+', district: 'Bengaluru Urban', state: 'Karnataka', isVerified: true, isClaimed: true, status: 'Active'),
      TreeCitizenNode(vuid: '819204918275', formattedVuid: '8192 0491 8275', name: 'Advait Sharma', gender: 'Male', dob: '2025-06-10', caste: 'Brahmin', category: 'GEN', gotra: 'Bharadwaj', religion: 'Hindu', maritalStatus: 'Single', bloodGroup: 'O+', district: 'Bengaluru Urban', state: 'Karnataka', isVerified: true, isClaimed: true, status: 'Active'),
    ];

    final edges = [
      // Spouses
      KinshipEdge(source: '109284729102', target: '109284729103', type: 'Spouse', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340192', target: '510928340193', type: 'Spouse', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '391029485710', target: '391029485711', type: 'Spouse', status: 'Unverified'),
      KinshipEdge(source: '510928340194', target: '510928340195', type: 'Spouse', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '284910293847', target: '928174019284', type: 'Spouse', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '710293849103', target: '710293849102', type: 'Spouse', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '284910293849', target: '710293849104', type: 'Spouse', status: 'Mutual_Confirmed'),

      // Gen 1 -> Gen 2 (Kailash & Savitri -> 3 Sons)
      KinshipEdge(source: '109284729102', target: '510928340192', type: 'Father', status: 'Document_Backed'),
      KinshipEdge(source: '109284729103', target: '510928340192', type: 'Mother', status: 'Document_Backed'),
      KinshipEdge(source: '109284729102', target: '391029485710', type: 'Father', status: 'Document_Backed'),
      KinshipEdge(source: '109284729103', target: '391029485710', type: 'Mother', status: 'Document_Backed'),
      KinshipEdge(source: '109284729102', target: '510928340194', type: 'Father', status: 'Document_Backed'),
      KinshipEdge(source: '109284729103', target: '510928340194', type: 'Mother', status: 'Document_Backed'),

      // Gen 2 -> Gen 3 (Ramesh & Sunita -> 3 Kids: Aarav, Ananya, Ishaan)
      KinshipEdge(source: '510928340192', target: '284910293847', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340193', target: '284910293847', type: 'Mother', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340192', target: '710293849103', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340193', target: '710293849103', type: 'Mother', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340192', target: '284910293849', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340193', target: '284910293849', type: 'Mother', status: 'Mutual_Confirmed'),

      // Gen 2 -> Gen 3 (Deepak & Meena -> 2 Kids: Priyanshu, Riya)
      KinshipEdge(source: '391029485710', target: '391029485712', type: 'Father', status: 'Unverified'),
      KinshipEdge(source: '391029485711', target: '391029485712', type: 'Mother', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '391029485710', target: '391029485713', type: 'Father', status: 'Unverified'),
      KinshipEdge(source: '391029485711', target: '391029485713', type: 'Mother', status: 'Mutual_Confirmed'),

      // Gen 2 -> Gen 3 (Vikram & Anita -> 2 Kids: Kabir, Diya)
      KinshipEdge(source: '510928340194', target: '510928340196', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340195', target: '510928340196', type: 'Mother', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340194', target: '510928340197', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '510928340195', target: '510928340197', type: 'Mother', status: 'Mutual_Confirmed'),

      // Gen 3 -> Gen 4 (Aarav & Pooja -> 2 Kids: Vihaan, Advait)
      KinshipEdge(source: '284910293847', target: '819204918274', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '928174019284', target: '819204918274', type: 'Mother', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '284910293847', target: '819204918275', type: 'Father', status: 'Mutual_Confirmed'),
      KinshipEdge(source: '928174019284', target: '819204918275', type: 'Mother', status: 'Mutual_Confirmed'),
    ];

    return TreeGraphData(
      rootVuid: '109284729102',
      formattedRootVuid: '1092 8472 9102',
      nodes: nodes,
      edges: edges,
    );
  }

  Future<void> fetchTree(String vuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get(ApiEndpoints.treeFetch(vuid));

      final graphData = TreeGraphData.fromJson(response);
      _computeNodeCoordinates(graphData);

      state = state.copyWith(isLoading: false, graphData: graphData);
    } catch (e) {
      // Offline / API Fallback: Render complete database seed graph
      final fallbackGraph = createDatabaseSeedGraph();
      _computeNodeCoordinates(fallbackGraph);
      state = state.copyWith(isLoading: false, graphData: fallbackGraph);
    }
  }

  Future<bool> connectKinship({
    required String sourceVuid,
    required String targetVuid,
    required String relationshipType,
  }) async {
    try {
      final client = _ref.read(apiClientProvider);
      await client.post(
        ApiEndpoints.kinshipConnect,
        body: {
          'source_vuid': sourceVuid,
          'target_vuid': targetVuid,
          'relationship_type': relationshipType,
        },
      );
      // Refresh current graph
      await fetchTree(sourceVuid);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  void removeNode(String vuid) {
    if (state.graphData == null) return;

    final currentGraph = state.graphData!;
    final updatedNodes = currentGraph.nodes.where((n) => n.vuid != vuid).toList();
    final updatedEdges = currentGraph.edges
        .where((e) => e.source != vuid && e.target != vuid)
        .toList();

    final newGraph = TreeGraphData(
      rootVuid: currentGraph.rootVuid == vuid
          ? (updatedNodes.isNotEmpty ? updatedNodes.first.vuid : '')
          : currentGraph.rootVuid,
      formattedRootVuid: currentGraph.formattedRootVuid,
      nodes: updatedNodes,
      edges: updatedEdges,
    );

    _computeNodeCoordinates(newGraph);
    state = state.copyWith(graphData: newGraph);
  }

  void updateNode(TreeCitizenNode updatedNode) {
    if (state.graphData == null) return;

    final currentGraph = state.graphData!;
    final updatedNodes = currentGraph.nodes.map((n) {
      if (n.vuid == updatedNode.vuid) {
        return updatedNode;
      }
      return n;
    }).toList();

    final newGraph = TreeGraphData(
      rootVuid: currentGraph.rootVuid,
      formattedRootVuid: currentGraph.formattedRootVuid,
      nodes: updatedNodes,
      edges: currentGraph.edges,
    );

    _computeNodeCoordinates(newGraph);
    state = state.copyWith(graphData: newGraph);
  }

  // Automatic multi-generational coordinate assignment for 2D Canvas layout
  void _computeNodeCoordinates(TreeGraphData graph) {
    if (graph.nodes.isEmpty) return;

    const double cardWidth = 170.0;
    const double spouseGap = 65.0; // Spacious gap between married spouses
    const double siblingGap = 150.0; // Generous breathing room between separate family units / siblings
    const double vGap = 340.0; // Ample vertical distance between generations
    const double centerX = 1600.0;
    const double centerY = 60.0;

    final rootNode = graph.nodes.firstWhere(
      (n) => n.vuid == graph.rootVuid,
      orElse: () => graph.nodes.first,
    );

    // 1. Assign generation levels (relative to root)
    final levels = <String, int>{};
    levels[rootNode.vuid] = 0;

    bool changed = true;
    int maxPasses = 15;
    while (changed && maxPasses-- > 0) {
      changed = false;
      for (final edge in graph.edges) {
        if (edge.type == 'Father' ||
            edge.type == 'Mother' ||
            edge.type == 'Guardian' ||
            edge.type.startsWith('Adopt') ||
            edge.type.contains('Adopt')) {
          if (levels.containsKey(edge.source) && !levels.containsKey(edge.target)) {
            levels[edge.target] = levels[edge.source]! + 1;
            changed = true;
          } else if (levels.containsKey(edge.target) && !levels.containsKey(edge.source)) {
            levels[edge.source] = levels[edge.target]! - 1;
            changed = true;
          }
        } else if (edge.type == 'Spouse' || edge.type == 'Sibling') {
          if (levels.containsKey(edge.source) && !levels.containsKey(edge.target)) {
            levels[edge.target] = levels[edge.source]!;
            changed = true;
          } else if (levels.containsKey(edge.target) && !levels.containsKey(edge.source)) {
            levels[edge.source] = levels[edge.target]!;
            changed = true;
          }
        }
      }
    }

    for (final node in graph.nodes) {
      levels.putIfAbsent(node.vuid, () => 0);
    }

    // 2. Group nodes by generation level
    final levelGroups = <int, List<TreeCitizenNode>>{};
    for (final node in graph.nodes) {
      final lvl = levels[node.vuid]!;
      levelGroups.putIfAbsent(lvl, () => []).add(node);
    }

    final sortedLevels = levelGroups.keys.toList()..sort();
    final minLvl = sortedLevels.first;

    // 3. Build spouse map
    final spouseMap = <String, String>{};
    for (final edge in graph.edges) {
      if (edge.type == 'Spouse') {
        spouseMap[edge.source] = edge.target;
        spouseMap[edge.target] = edge.source;
      }
    }

    // 4. Build child-to-parents map
    final childParentsMap = <String, List<String>>{};
    for (final edge in graph.edges) {
      if (edge.type == 'Father' || edge.type == 'Mother' || edge.type.contains('Adopt')) {
        childParentsMap.putIfAbsent(edge.target, () => []).add(edge.source);
      }
    }

    // Map to keep track of calculated position of each node
    final positionMap = <String, Offset>{};

    for (final lvl in sortedLevels) {
      final rawNodes = levelGroups[lvl]!;
      final double posY = centerY + (lvl - minLvl) * vGap;

      // Build visual blocks for this level (each block is a couple [husband, wife] or single person [person])
      final visitedInLevel = <String>{};
      final blocks = <List<TreeCitizenNode>>[];

      for (final node in rawNodes) {
        if (visitedInLevel.contains(node.vuid)) continue;

        final spouseVuid = spouseMap[node.vuid];
        if (spouseVuid != null && rawNodes.any((n) => n.vuid == spouseVuid)) {
          final spouseNode = rawNodes.firstWhere((n) => n.vuid == spouseVuid);
          final husband = node.gender.toLowerCase() == 'male' ? node : spouseNode;
          final wife = node.gender.toLowerCase() == 'male' ? spouseNode : node;

          blocks.add([husband, wife]);
          visitedInLevel.add(husband.vuid);
          visitedInLevel.add(wife.vuid);
        } else {
          blocks.add([node]);
          visitedInLevel.add(node.vuid);
        }
      }

      // Group blocks by parent unit key
      final familyUnitBlocks = <String, List<List<TreeCitizenNode>>>{};
      for (final block in blocks) {
        // Determine parent key for the block (check if any member of the block has parents in tree)
        List<String> parents = [];
        for (final member in block) {
          if (childParentsMap.containsKey(member.vuid)) {
            parents = childParentsMap[member.vuid]!;
            break;
          }
        }
        final parentKey = parents.isNotEmpty ? (List.of(parents)..sort()).join('-') : 'default-group';
        familyUnitBlocks.putIfAbsent(parentKey, () => []).add(block);
      }

      double currentX = centerX;
      bool firstUnit = true;

      for (final parentKey in familyUnitBlocks.keys) {
        final unitBlocks = familyUnitBlocks[parentKey]!;

        // Compute total width of this family unit (sum of block widths + sibling gaps)
        double unitWidth = 0.0;
        for (int b = 0; b < unitBlocks.length; b++) {
          final block = unitBlocks[b];
          final blockWidth = block.length == 2 ? (cardWidth * 2 + spouseGap) : cardWidth;
          unitWidth += blockWidth;
          if (b < unitBlocks.length - 1) {
            unitWidth += siblingGap;
          }
        }

        // Determine target center X for this unit from parent positions
        double targetCenterX = centerX;
        if (parentKey != 'default-group') {
          final parentVuids = parentKey.split('-');
          final parentPositions = parentVuids
              .where((v) => positionMap.containsKey(v))
              .map((v) => positionMap[v]!)
              .toList();

          if (parentPositions.isNotEmpty) {
            final parentMinX = parentPositions.map((p) => p.dx).reduce(min);
            final parentMaxX = parentPositions.map((p) => p.dx).reduce(max);
            targetCenterX = (parentMinX + parentMaxX + cardWidth) / 2;
          }
        }

        double unitStartX = targetCenterX - unitWidth / 2;
        if (!firstUnit && unitStartX < currentX + siblingGap) {
          unitStartX = currentX + siblingGap;
        }

        double xCursor = unitStartX;
        for (int b = 0; b < unitBlocks.length; b++) {
          final block = unitBlocks[b];
          if (block.length == 2) {
            // Married Couple: Husband on left, Wife on right
            final husband = block[0];
            final wife = block[1];

            husband.position = Offset(xCursor, posY);
            positionMap[husband.vuid] = husband.position;
            xCursor += cardWidth + spouseGap;

            wife.position = Offset(xCursor, posY);
            positionMap[wife.vuid] = wife.position;
            xCursor += cardWidth;
          } else {
            // Single person
            final node = block[0];
            node.position = Offset(xCursor, posY);
            positionMap[node.vuid] = node.position;
            xCursor += cardWidth;
          }

          if (b < unitBlocks.length - 1) {
            xCursor += siblingGap;
          }
        }

        currentX = xCursor;
        firstUnit = false;
      }
    }

    // 5. Ensure all node coordinates are centered around canvas midpoint (1200.0)
    if (graph.nodes.isNotEmpty) {
      final double minX = graph.nodes.map((n) => n.position.dx).reduce(min);
      final double maxX = graph.nodes.map((n) => n.position.dx).reduce(max);
      final double minY = graph.nodes.map((n) => n.position.dy).reduce(min);

      final double treeMidX = (minX + maxX + cardWidth) / 2;
      const double targetCanvasMidX = 1600.0;
      const double targetMinY = 60.0;

      final double shiftX = targetCanvasMidX - treeMidX;
      final double shiftY = targetMinY - minY;

      for (final node in graph.nodes) {
        node.position = Offset(node.position.dx + shiftX, node.position.dy + shiftY);
      }
    }
  }
}

final treeProvider = StateNotifierProvider<TreeNotifier, TreeState>((ref) {
  return TreeNotifier(ref);
});
