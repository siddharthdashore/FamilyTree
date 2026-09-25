import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Parses database/seed.sql to extract citizens and relationships for the tree.
  static Future<TreeGraphData> loadSeedGraphFromJson() async {
    try {
      final String sqlStr = await rootBundle.loadString('../database/seed.sql');
      return _parseSeedSQL(sqlStr);
    } catch (_) {
      return TreeGraphData(
        rootVuid: '109284729102',
        formattedRootVuid: '1092 8472 9102',
        nodes: [],
        edges: [],
      );
    }
  }

  /// Parses INSERT statements from seed.sql to build the graph data.
  static TreeGraphData _parseSeedSQL(String sql) {
    final List<Map<String, dynamic>> citizens = [];
    final List<Map<String, dynamic>> relationships = [];

    // Parse citizens INSERT block
    final citizenMatch = RegExp(
      r"INSERT INTO `citizens`\s*\([^)]+\)\s*VALUES\s*([\s\S]*?);",
    ).firstMatch(sql);
    if (citizenMatch != null) {
      final valuesBlock = citizenMatch.group(1)!;
      final rowRegex = RegExp(r"\(([^)]+)\)");
      for (final match in rowRegex.allMatches(valuesBlock)) {
        final vals = _parseSqlRow(match.group(1)!);
        if (vals.length >= 19) {
          citizens.add({
            'vuid': vals[0],
            'first_name': vals[1],
            'middle_name': vals[2] == 'NULL' ? null : vals[2],
            'last_name': vals[3],
            'gender': vals[4],
            'dob': vals[5],
            'caste': vals[6],
            'category': vals[7],
            'gotra': vals[8],
            'religion': vals[9],
            'marital_status': vals[10],
            'blood_group': vals[11],
            'address_line1': vals[12],
            'district': vals[14],
            'state': vals[15],
            'status': vals[18],
          });
        }
      }
    }

    // Parse relationships INSERT block
    final relMatch = RegExp(
      r"INSERT INTO `relationships`\s*\([^)]+\)\s*VALUES\s*([\s\S]*?);",
    ).firstMatch(sql);
    if (relMatch != null) {
      final valuesBlock = relMatch.group(1)!;
      final rowRegex = RegExp(r"\(([^)]+)\)");
      for (final match in rowRegex.allMatches(valuesBlock)) {
        final vals = _parseSqlRow(match.group(1)!);
        if (vals.length >= 4) {
          relationships.add({
            'source_vuid': vals[0],
            'target_vuid': vals[1],
            'relationship_type': vals[2],
            'verification_status': vals[3],
          });
        }
      }
    }

    return TreeGraphData.fromJson({
      'root_vuid': '109284729102',
      'citizens': citizens,
      'relationships': relationships,
    });
  }

  /// Parses a single SQL VALUES row, respecting quoted strings.
  static List<String> _parseSqlRow(String raw) {
    final List<String> vals = [];
    String current = '';
    bool inQuote = false;
    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == "'" && (i == 0 || raw[i - 1] != '\\')) {
        inQuote = !inQuote;
      } else if (ch == ',' && !inQuote) {
        vals.add(current.trim());
        current = '';
      } else {
        current += ch;
      }
    }
    vals.add(current.trim());
    return vals;
  }

  static TreeGraphData createDatabaseSeedGraph() {
    return TreeGraphData(
      rootVuid: '109284729102',
      formattedRootVuid: '1092 8472 9102',
      nodes: [],
      edges: [],
    );
  }

  Future<void> _saveGraphToLocalStorage(TreeGraphData graph) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(graph.toJson());
      await prefs.setString('persisted_tree_graph_${graph.rootVuid}', jsonStr);
      await prefs.setString('persisted_tree_graph_latest', jsonStr);
    } catch (_) {}
  }

  Future<TreeGraphData?> _loadGraphFromLocalStorage(String vuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonStr = prefs.getString('persisted_tree_graph_$vuid');
      jsonStr ??= prefs.getString('persisted_tree_graph_latest');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return TreeGraphData.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  Future<void> fetchTree(String vuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get(ApiEndpoints.treeFetch(vuid));

      final graphData = TreeGraphData.fromJson(response);
      _computeNodeCoordinates(graphData);
      await _saveGraphToLocalStorage(graphData);

      state = state.copyWith(isLoading: false, graphData: graphData);
    } catch (e) {
      // Offline / Local JSON Persistence Fallback: Try loading persisted local graph first!
      final localGraph = await _loadGraphFromLocalStorage(vuid);
      if (localGraph != null && localGraph.nodes.isNotEmpty) {
        _computeNodeCoordinates(localGraph);
        state = state.copyWith(isLoading: false, graphData: localGraph);
      } else {
        final fallbackGraph = await loadSeedGraphFromJson();
        _computeNodeCoordinates(fallbackGraph);
        await _saveGraphToLocalStorage(fallbackGraph);
        state = state.copyWith(isLoading: false, graphData: fallbackGraph);
      }
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

  Future<bool> recordDivorce({
    required String spouse1Vuid,
    required String spouse2Vuid,
  }) async {
    try {
      final client = _ref.read(apiClientProvider);
      await client.post(
        ApiEndpoints.eventDivorce,
        body: {
          'spouse1_vuid': spouse1Vuid,
          'spouse2_vuid': spouse2Vuid,
          'divorce_date': DateTime.now().toIso8601String().split('T').first,
        },
      );
      await fetchTree(spouse1Vuid);
      return true;
    } catch (e) {
      // Offline fallback: update graph edges in memory
      if (state.graphData != null) {
        final currentGraph = state.graphData!;
        final updatedEdges = currentGraph.edges.map((edge) {
          final isTargetPair = (edge.source == spouse1Vuid && edge.target == spouse2Vuid) ||
              (edge.source == spouse2Vuid && edge.target == spouse1Vuid);
          if (edge.type == 'Spouse' && isTargetPair) {
            return KinshipEdge(
              source: edge.source,
              target: edge.target,
              type: 'Spouse',
              status: 'Divorced',
            );
          }
          return edge;
        }).toList();

        final updatedNodes = currentGraph.nodes.map((node) {
          if (node.vuid == spouse1Vuid || node.vuid == spouse2Vuid) {
            return TreeCitizenNode(
              vuid: node.vuid,
              formattedVuid: node.formattedVuid,
              name: node.name,
              gender: node.gender,
              dob: node.dob,
              caste: node.caste,
              category: node.category,
              gotra: node.gotra,
              religion: node.religion,
              maritalStatus: 'Divorced',
              bloodGroup: node.bloodGroup,
              district: node.district,
              state: node.state,
              isVerified: node.isVerified,
              isClaimed: node.isClaimed,
              status: node.status,
              position: node.position,
            );
          }
          return node;
        }).toList();

        final newGraph = TreeGraphData(
          rootVuid: currentGraph.rootVuid,
          formattedRootVuid: currentGraph.formattedRootVuid,
          nodes: updatedNodes,
          edges: updatedEdges,
        );
        _computeNodeCoordinates(newGraph);
        await _saveGraphToLocalStorage(newGraph);
        state = state.copyWith(graphData: newGraph);
      }
      return true;
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
    _saveGraphToLocalStorage(newGraph);
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
    _saveGraphToLocalStorage(newGraph);
    state = state.copyWith(graphData: newGraph);
  }

  // Automatic multi-generational coordinate assignment for 2D Canvas layout
  void _computeNodeCoordinates(TreeGraphData graph) {
    if (graph.nodes.isEmpty) return;

    const double cardWidth = 170.0;
    const double spouseGap = 40.0; // Gap between married spouses
    const double siblingGap = 80.0; // Breathing room between separate family units
    const double vGap = 200.0; // Vertical distance between generations
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
    int maxPasses = 25;
    while (changed && maxPasses-- > 0) {
      changed = false;
      for (final edge in graph.edges) {
        final t = edge.type.toLowerCase();
        if (t == 'father' || t == 'mother' || t == 'guardian' || t.contains('adopt')) {
          if (levels.containsKey(edge.source) && !levels.containsKey(edge.target)) {
            levels[edge.target] = levels[edge.source]! + 1;
            changed = true;
          } else if (levels.containsKey(edge.target) && !levels.containsKey(edge.source)) {
            levels[edge.source] = levels[edge.target]! - 1;
            changed = true;
          }
        } else if (t == 'spouse' || t == 'sibling') {
          if (levels.containsKey(edge.source) && !levels.containsKey(edge.target)) {
            levels[edge.target] = levels[edge.source]!;
            changed = true;
          } else if (levels.containsKey(edge.target) && !levels.containsKey(edge.source)) {
            levels[edge.source] = levels[edge.target]!;
            changed = true;
          } else if (t == 'spouse' && levels.containsKey(edge.source) && levels.containsKey(edge.target)) {
            if (levels[edge.source] != levels[edge.target]) {
              levels[edge.target] = levels[edge.source]!;
              changed = true;
            }
          }
        }
      }
    }

    // Guarantee unassigned nodes inherit their level from any connected spouse or parent edge
    for (final node in graph.nodes) {
      if (!levels.containsKey(node.vuid)) {
        // 1. Try spouse edge
        final spouseEdge = graph.edges.firstWhere(
          (e) => (e.type.isEmpty || e.type.toLowerCase() == 'spouse') &&
                 ((e.source == node.vuid && levels.containsKey(e.target)) ||
                  (e.target == node.vuid && levels.containsKey(e.source))),
          orElse: () => KinshipEdge(source: '', target: '', type: '', status: ''),
        );
        if (spouseEdge.source.isNotEmpty) {
          final partnerVuid = spouseEdge.source == node.vuid ? spouseEdge.target : spouseEdge.source;
          levels[node.vuid] = levels[partnerVuid]!;
          continue;
        }

        // 2. Try parent edge (as child)
        final parentEdge = graph.edges.firstWhere(
          (e) => (e.target == node.vuid && levels.containsKey(e.source)),
          orElse: () => KinshipEdge(source: '', target: '', type: '', status: ''),
        );
        if (parentEdge.source.isNotEmpty) {
          levels[node.vuid] = levels[parentEdge.source]! + 1;
          continue;
        }

        // 3. Fallback: place on bottom level if completely unconnected
        final maxLvl = levels.values.isNotEmpty ? levels.values.reduce(max) : 0;
        levels[node.vuid] = maxLvl + 1;
      }
    }

    // 2. Group nodes by generation level
    final levelGroups = <int, List<TreeCitizenNode>>{};
    for (final node in graph.nodes) {
      final lvl = levels[node.vuid]!;
      levelGroups.putIfAbsent(lvl, () => []).add(node);
    }

    final sortedLevels = levelGroups.keys.toList()..sort();
    final minLvl = sortedLevels.first;

    // 3. Build multi-spouse map (case-insensitive)
    final spouseMap = <String, List<String>>{};
    for (final edge in graph.edges) {
      if (edge.type.toLowerCase() == 'spouse') {
        spouseMap.putIfAbsent(edge.source, () => []).add(edge.target);
        spouseMap.putIfAbsent(edge.target, () => []).add(edge.source);
      }
    }

    // 4. Build child-to-parents map
    final childParentsMap = <String, List<String>>{};
    for (final edge in graph.edges) {
      final t = edge.type.toLowerCase();
      if (t == 'father' || t == 'mother' || t.contains('adopt')) {
        childParentsMap.putIfAbsent(edge.target, () => []).add(edge.source);
      }
    }

    // Map to keep track of calculated position of each node
    final positionMap = <String, Offset>{};

    for (final lvl in sortedLevels) {
      final rawNodes = levelGroups[lvl]!;
      final double posY = centerY + (lvl - minLvl) * vGap;

      // Build visual blocks for this level (each block is a spouse cluster [spouse1, person, spouse2] or single person)
      final visitedInLevel = <String>{};
      final blocks = <List<TreeCitizenNode>>[];

      for (final node in rawNodes) {
        if (visitedInLevel.contains(node.vuid)) continue;

        final spouseVuids = (spouseMap[node.vuid] ?? [])
            .where((v) => rawNodes.any((n) => n.vuid == v))
            .toList();

        if (spouseVuids.isNotEmpty) {
          final spouseNodes = spouseVuids
              .map((v) => rawNodes.firstWhere((n) => n.vuid == v))
              .toList();

          final block = <TreeCitizenNode>[];
          if (spouseNodes.length == 1) {
            final spouseNode = spouseNodes.first;
            final husband = node.gender.toLowerCase() == 'male' ? node : spouseNode;
            final wife = node.gender.toLowerCase() == 'male' ? spouseNode : node;
            block.addAll([husband, wife]);
          } else {
            // Multiple spouses: group former spouses on left, central node in middle, current spouse on right
            final formerSpouses = spouseNodes.where((s) {
              final edge = graph.edges.firstWhere(
                (e) => e.type.toLowerCase() == 'spouse' && ((e.source == node.vuid && e.target == s.vuid) || (e.source == s.vuid && e.target == node.vuid)),
                orElse: () => KinshipEdge(source: '', target: '', type: '', status: ''),
              );
              final status = edge.status.toLowerCase();
              return status == 'divorced' || status == 'former' || status == 'separated' || status == 'ex';
            }).toList();

            final currentSpouses = spouseNodes.where((s) => !formerSpouses.contains(s)).toList();

            block.addAll(formerSpouses);
            block.add(node);
            block.addAll(currentSpouses);
          }

          blocks.add(block);
          for (final m in block) {
            visitedInLevel.add(m.vuid);
          }
        } else {
          blocks.add([node]);
          visitedInLevel.add(node.vuid);
        }
      }

      // Group blocks by parent unit key
      final familyUnitBlocks = <String, List<List<TreeCitizenNode>>>{};
      for (final block in blocks) {
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

      // Sort family units by parent center X position (left → right)
      final sortedKeys = familyUnitBlocks.keys.toList()..sort((a, b) {
        double parentCenterOf(String key) {
          if (key == 'default-group') return centerX;
          final parents = key.split('-');
          final xs = parents
              .where((v) => positionMap.containsKey(v))
              .map((v) => positionMap[v]!.dx + cardWidth / 2);
          if (xs.isEmpty) return centerX;
          return xs.reduce((a, b) => a + b) / xs.length;
        }
        return parentCenterOf(a).compareTo(parentCenterOf(b));
      });

      // Compute target center and width for each unit
      final unitTargetCenters = <double>[];
      final unitWidths = <double>[];

      for (final key in sortedKeys) {
        final unitBlocks = familyUnitBlocks[key]!;
        double w = 0.0;
        for (int b = 0; b < unitBlocks.length; b++) {
          w += unitBlocks[b].length * cardWidth + (unitBlocks[b].length - 1) * spouseGap;
          if (b < unitBlocks.length - 1) w += siblingGap;
        }
        unitWidths.add(w);

        double target = centerX;
        if (key != 'default-group') {
          final parentVuids = key.split('-');
          final parentXs = parentVuids
              .where((v) => positionMap.containsKey(v))
              .map((v) => positionMap[v]!.dx)
              .toList();
          if (parentXs.isNotEmpty) {
            final pMinX = parentXs.reduce(min);
            final pMaxX = parentXs.reduce(max);
            target = (pMinX + pMaxX + cardWidth) / 2;
          }
        }
        unitTargetCenters.add(target);
      }

      // Compute start X for each unit, centered on target
      final startXs = List.generate(sortedKeys.length,
          (i) => unitTargetCenters[i] - unitWidths[i] / 2);

      // Resolve overlaps left-to-right
      for (int i = 1; i < startXs.length; i++) {
        final prevEnd = startXs[i - 1] + unitWidths[i - 1];
        if (startXs[i] < prevEnd + siblingGap) {
          startXs[i] = prevEnd + siblingGap;
        }
      }

      // Place members within each unit
      for (int u = 0; u < sortedKeys.length; u++) {
        final unitBlocks = familyUnitBlocks[sortedKeys[u]]!;
        double xCursor = startXs[u];
        for (int b = 0; b < unitBlocks.length; b++) {
          final block = unitBlocks[b];
          for (int i = 0; i < block.length; i++) {
            final member = block[i];
            member.position = Offset(xCursor, posY);
            positionMap[member.vuid] = member.position;
            if (i < block.length - 1) {
              xCursor += cardWidth + spouseGap;
            } else {
              xCursor += cardWidth;
            }
          }
          if (b < unitBlocks.length - 1) {
            xCursor += siblingGap;
          }
        }
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
