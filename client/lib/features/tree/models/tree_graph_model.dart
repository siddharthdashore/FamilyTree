import 'package:flutter/material.dart';

class TreeCitizenNode {
  final String vuid;
  final String formattedVuid;
  final String name;
  final String gender;
  final String dob;
  final String caste;
  final String category;
  final String gotra;
  final String religion;
  final String maritalStatus;
  final String bloodGroup;
  final String district;
  final String state;
  final bool isVerified;
  final bool isClaimed;
  final String status;
  Offset position;

  TreeCitizenNode({
    required this.vuid,
    required this.formattedVuid,
    required this.name,
    required this.gender,
    required this.dob,
    this.caste = 'Brahmin',
    required this.category,
    this.gotra = 'Bharadwaj',
    this.religion = 'Hindu',
    this.maritalStatus = 'Single',
    this.bloodGroup = 'O+',
    this.district = 'Indore',
    this.state = 'Madhya Pradesh',
    required this.isVerified,
    required this.isClaimed,
    required this.status,
    this.position = Offset.zero,
  });

  factory TreeCitizenNode.fromJson(Map<String, dynamic> json) {
    Offset pos = Offset.zero;
    if (json['pos_dx'] != null && json['pos_dy'] != null) {
      pos = Offset(
        (json['pos_dx'] as num).toDouble(),
        (json['pos_dy'] as num).toDouble(),
      );
    }
    return TreeCitizenNode(
      vuid: json['vuid'] ?? '',
      formattedVuid: json['formatted_vuid'] ?? json['vuid'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? 'Male',
      dob: json['dob'] ?? '',
      caste: json['caste'] ?? 'Brahmin',
      category: json['category'] ?? 'GEN',
      gotra: json['gotra'] ?? 'Bharadwaj',
      religion: json['religion'] ?? 'Hindu',
      maritalStatus: json['marital_status'] ?? json['maritalStatus'] ?? 'Single',
      bloodGroup: json['blood_group'] ?? json['bloodGroup'] ?? 'O+',
      district: json['district'] ?? 'Indore',
      state: json['state'] ?? 'Madhya Pradesh',
      isVerified: json['is_verified'] == true || json['is_verified'] == 1,
      isClaimed: json['is_claimed'] == true || json['is_claimed'] == 1,
      status: json['status'] ?? 'Active',
      position: pos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vuid': vuid,
      'formatted_vuid': formattedVuid,
      'name': name,
      'gender': gender,
      'dob': dob,
      'caste': caste,
      'category': category,
      'gotra': gotra,
      'religion': religion,
      'marital_status': maritalStatus,
      'blood_group': bloodGroup,
      'district': district,
      'state': state,
      'is_verified': isVerified,
      'is_claimed': isClaimed,
      'status': status,
      'pos_dx': position.dx,
      'pos_dy': position.dy,
    };
  }
}

class KinshipEdge {
  final String source;
  final String target;
  final String type;
  final String status;

  KinshipEdge({
    required this.source,
    required this.target,
    required this.type,
    required this.status,
  });

  factory KinshipEdge.fromJson(Map<String, dynamic> json) {
    return KinshipEdge(
      source: json['source'] ?? '',
      target: json['target'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'Unverified',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'target': target,
      'type': type,
      'status': status,
    };
  }
}

class TreeGraphData {
  final String rootVuid;
  final String formattedRootVuid;
  final List<TreeCitizenNode> nodes;
  final List<KinshipEdge> edges;

  TreeGraphData({
    required this.rootVuid,
    required this.formattedRootVuid,
    required this.nodes,
    required this.edges,
  });

  factory TreeGraphData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('citizens') && json['citizens'] is List) {
      return TreeGraphData.fromDbStoreJson(json);
    }

    final nodesRaw = json['nodes'] as List? ?? [];
    final edgesRaw = json['edges'] as List? ?? [];

    final parsedNodes = nodesRaw.map((n) => TreeCitizenNode.fromJson(n)).toList();
    final parsedEdges = edgesRaw.map((e) => KinshipEdge.fromJson(e)).toList();

    // Deduplicate nodes by VUID (prevents duplicate overlays in Stack)
    final seenVuids = <String>{};
    final uniqueNodes = <TreeCitizenNode>[];
    for (final node in parsedNodes) {
      if (node.vuid.isNotEmpty && !seenVuids.contains(node.vuid)) {
        seenVuids.add(node.vuid);
        uniqueNodes.add(node);
      }
    }

    // Deduplicate and sanitize edges
    final seenEdges = <String>{};
    final uniqueEdges = <KinshipEdge>[];
    for (final edge in parsedEdges) {
      if (edge.source.isEmpty || edge.target.isEmpty) continue;
      String type = edge.type;
      if (type.isEmpty) {
        type = 'Spouse';
      }
      final edgeKey = '${edge.source}_${edge.target}_$type';
      if (!seenEdges.contains(edgeKey)) {
        seenEdges.add(edgeKey);
        uniqueEdges.add(KinshipEdge(
          source: edge.source,
          target: edge.target,
          type: type,
          status: edge.status.isEmpty ? 'Mutual_Confirmed' : edge.status,
        ));
      }
    }

    return TreeGraphData(
      rootVuid: json['root_vuid'] ?? '',
      formattedRootVuid: json['formatted_root_vuid'] ?? json['root_vuid'] ?? '',
      nodes: uniqueNodes,
      edges: uniqueEdges,
    );
  }

  factory TreeGraphData.fromDbStoreJson(Map<String, dynamic> json, {String rootVuid = '109284729102'}) {
    final rawCitizens = json['citizens'] as List? ?? [];
    final rawRelationships = json['relationships'] as List? ?? [];

    String formatVUID(String v) {
      if (v.length == 12) {
        return '${v.substring(0, 4)} ${v.substring(4, 8)} ${v.substring(8, 12)}';
      }
      return v;
    }

    final parsedNodes = rawCitizens.map((c) {
      final firstName = c['first_name'] ?? '';
      final middleName = c['middle_name'] ?? '';
      final lastName = c['last_name'] ?? '';
      final nameParts = [firstName, middleName, lastName].where((s) => s != null && s.toString().trim().isNotEmpty).join(' ');
      final vuid = c['vuid']?.toString() ?? '';

      return TreeCitizenNode(
        vuid: vuid,
        formattedVuid: formatVUID(vuid),
        name: nameParts,
        gender: c['gender'] ?? 'Male',
        dob: c['dob'] ?? '',
        caste: c['caste'] ?? 'Brahmin',
        category: c['category'] ?? 'GEN',
        gotra: c['gotra'] ?? 'Bharadwaj',
        religion: c['religion'] ?? 'Hindu',
        maritalStatus: c['marital_status'] ?? 'Single',
        bloodGroup: c['blood_group'] ?? 'O+',
        district: c['district'] ?? 'Indore',
        state: c['state'] ?? 'Madhya Pradesh',
        isVerified: true,
        isClaimed: c['is_claimed'] == 1 || c['is_claimed'] == true,
        status: c['status'] ?? 'Active',
      );
    }).toList();

    final parsedEdges = rawRelationships.map((r) {
      return KinshipEdge(
        source: r['source_vuid']?.toString() ?? r['source']?.toString() ?? '',
        target: r['target_vuid']?.toString() ?? r['target']?.toString() ?? '',
        type: r['relationship_type']?.toString() ?? r['type']?.toString() ?? 'Spouse',
        status: r['verification_status']?.toString() ?? r['status']?.toString() ?? 'Mutual_Confirmed',
      );
    }).toList();

    return TreeGraphData(
      rootVuid: rootVuid,
      formattedRootVuid: formatVUID(rootVuid),
      nodes: parsedNodes,
      edges: parsedEdges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'root_vuid': rootVuid,
      'formatted_root_vuid': formattedRootVuid,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }
}
