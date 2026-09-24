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

  Future<void> fetchTree(String vuid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.get(ApiEndpoints.treeFetch(vuid));

      final graphData = TreeGraphData.fromJson(response);
      _computeNodeCoordinates(graphData);

      state = state.copyWith(isLoading: false, graphData: graphData);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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

  // Automatic coordinate assignment for 2D Canvas layout
  void _computeNodeCoordinates(TreeGraphData graph) {
    if (graph.nodes.isEmpty) return;

    const double cardWidth = 170.0;
    const double cardHeight = 140.0;
    const double hGap = 60.0;
    const double vGap = 140.0;
    const double centerX = 500.0;
    const double centerY = 400.0;

    // Categorize nodes by relationship to root
    final rootNode = graph.nodes.firstWhere(
      (n) => n.vuid == graph.rootVuid,
      orElse: () => graph.nodes.first,
    );

    rootNode.position = const Offset(centerX, centerY);

    final parents = <TreeCitizenNode>[];
    final spouses = <TreeCitizenNode>[];
    final children = <TreeCitizenNode>[];
    final siblings = <TreeCitizenNode>[];
    final others = <TreeCitizenNode>[];

    for (final node in graph.nodes) {
      if (node.vuid == rootNode.vuid) continue;

      // Find relationship with root
      final edge = graph.edges.firstWhere(
        (e) => (e.source == node.vuid && e.target == rootNode.vuid) ||
               (e.target == node.vuid && e.source == rootNode.vuid),
        orElse: () => KinshipEdge(source: '', target: '', type: 'Other', status: ''),
      );

      if (edge.type == 'Father' || edge.type == 'Mother' || edge.type == 'Guardian') {
        parents.add(node);
      } else if (edge.type == 'Spouse') {
        spouses.add(node);
      } else if (edge.type == 'Son' || edge.type == 'Daughter') {
        children.add(node);
      } else if (edge.type == 'Sibling') {
        siblings.add(node);
      } else {
        others.add(node);
      }
    }

    // Place Spouses to the right of root
    for (int i = 0; i < spouses.length; i++) {
      spouses[i].position = Offset(
        centerX + (i + 1) * (cardWidth + hGap),
        centerY,
      );
    }

    // Place Parents above root
    final double parentStartX = centerX - ((parents.length - 1) * (cardWidth + hGap)) / 2;
    for (int i = 0; i < parents.length; i++) {
      parents[i].position = Offset(
        parentStartX + i * (cardWidth + hGap),
        centerY - (cardHeight + vGap),
      );
    }

    // Place Children below root
    final double childStartX = centerX - ((children.length - 1) * (cardWidth + hGap)) / 2;
    for (int i = 0; i < children.length; i++) {
      children[i].position = Offset(
        childStartX + i * (cardWidth + hGap),
        centerY + (cardHeight + vGap),
      );
    }

    // Place Siblings to the left of root
    for (int i = 0; i < siblings.length; i++) {
      siblings[i].position = Offset(
        centerX - (i + 1) * (cardWidth + hGap),
        centerY,
      );
    }

    // Place any remaining nodes
    for (int i = 0; i < others.length; i++) {
      others[i].position = Offset(
        centerX + (i + 1) * (cardWidth + hGap),
        centerY + (cardHeight + vGap) * 1.8,
      );
    }
  }
}

final treeProvider = StateNotifierProvider<TreeNotifier, TreeState>((ref) {
  return TreeNotifier(ref);
});
