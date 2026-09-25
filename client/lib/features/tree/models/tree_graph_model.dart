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
    );
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
    final nodesRaw = json['nodes'] as List? ?? [];
    final edgesRaw = json['edges'] as List? ?? [];

    return TreeGraphData(
      rootVuid: json['root_vuid'] ?? '',
      formattedRootVuid: json['formatted_root_vuid'] ?? json['root_vuid'] ?? '',
      nodes: nodesRaw.map((n) => TreeCitizenNode.fromJson(n)).toList(),
      edges: edgesRaw.map((e) => KinshipEdge.fromJson(e)).toList(),
    );
  }
}
