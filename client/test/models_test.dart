import 'package:flutter_test/flutter_test.dart';
import 'package:vanshasetu/features/auth/models/citizen_registration_model.dart';
import 'package:vanshasetu/features/tree/models/tree_graph_model.dart';

void main() {
  group('CitizenRegistrationModel Unit Tests', () {
    test('toJson: serializes all fields properly into JSON map', () {
      final model = CitizenRegistrationModel(
        firstName: 'Aarav',
        middleName: 'Prasad',
        lastName: 'Sharma',
        gender: 'Male',
        dob: '1998-05-18',
        heightCm: 178.5,
        weightKg: 72.0,
        caste: 'Brahmin',
        category: 'GEN',
        gotra: 'Bharadwaj',
        religion: 'Hindu',
        maritalStatus: 'Married',
        bloodGroup: 'B+',
        addressLine1: 'Flat 302, Green Meadows',
        addressLine2: 'HSR Layout',
        pinCode: '560102',
        district: 'Bengaluru Urban',
        state: 'Karnataka',
        country: 'India',
        latitude: 12.9116,
        longitude: 77.6499,
      );

      final json = model.toJson();

      expect(json['first_name'], 'Aarav');
      expect(json['middle_name'], 'Prasad');
      expect(json['last_name'], 'Sharma');
      expect(json['gender'], 'Male');
      expect(json['dob'], '1998-05-18');
      expect(json['height_cm'], 178.5);
      expect(json['weight_kg'], 72.0);
      expect(json['caste'], 'Brahmin');
      expect(json['category'], 'GEN');
      expect(json['gotra'], 'Bharadwaj');
      expect(json['religion'], 'Hindu');
      expect(json['marital_status'], 'Married');
      expect(json['blood_group'], 'B+');
      expect(json['address_line1'], 'Flat 302, Green Meadows');
      expect(json['address_line2'], 'HSR Layout');
      expect(json['pin_code'], '560102');
      expect(json['district'], 'Bengaluru Urban');
      expect(json['state'], 'Karnataka');
      expect(json['country'], 'India');
      expect(json['latitude'], 12.9116);
      expect(json['longitude'], 77.6499);
    });

    test('RegisteredCitizen.fromJson: parses valid JSON and sets fallbacks', () {
      final json = {
        'vuid': '109284729102',
        'formatted_vuid': '1092 8472 9102',
        'full_name': 'Kailash Sharma',
        'gender': 'Male',
        'category': 'GEN',
        'registered_at': '2026-09-24T00:00:00.000Z',
      };

      final citizen = RegisteredCitizen.fromJson(json);

      expect(citizen.vuid, '109284729102');
      expect(citizen.formattedVuid, '1092 8472 9102');
      expect(citizen.fullName, 'Kailash Sharma');
      expect(citizen.gender, 'Male');
      expect(citizen.category, 'GEN');
      expect(citizen.registeredAt, '2026-09-24T00:00:00.000Z');
    });

    test('RegisteredCitizen.fromJson: handles missing optional values gracefully', () {
      final json = <String, dynamic>{};
      final citizen = RegisteredCitizen.fromJson(json);

      expect(citizen.vuid, '');
      expect(citizen.formattedVuid, '');
      expect(citizen.fullName, '');
      expect(citizen.gender, 'Male');
      expect(citizen.category, 'GEN');
    });
  });

  group('TreeGraphModel Unit Tests', () {
    test('TreeCitizenNode.fromJson: correctly sets verification and claimed flags', () {
      final json = {
        'vuid': '284910293847',
        'formatted_vuid': '2849 1029 3847',
        'name': 'Aarav Sharma',
        'gender': 'Male',
        'dob': '1998-05-18',
        'category': 'GEN',
        'is_verified': 1,
        'is_claimed': true,
        'status': 'Active',
      };

      final node = TreeCitizenNode.fromJson(json);

      expect(node.vuid, '284910293847');
      expect(node.formattedVuid, '2849 1029 3847');
      expect(node.name, 'Aarav Sharma');
      expect(node.gender, 'Male');
      expect(node.isVerified, true);
      expect(node.isClaimed, true);
      expect(node.status, 'Active');
    });

    test('KinshipEdge.fromJson: parses directed kinship relationship edge', () {
      final json = {
        'source': '510928340192',
        'target': '284910293847',
        'type': 'Father',
        'status': 'Mutual_Confirmed',
      };

      final edge = KinshipEdge.fromJson(json);

      expect(edge.source, '510928340192');
      expect(edge.target, '284910293847');
      expect(edge.type, 'Father');
      expect(edge.status, 'Mutual_Confirmed');
    });

    test('TreeGraphData.fromJson: parses root citizen with multiple connected nodes and edges', () {
      final json = {
        'root_vuid': '284910293847',
        'formatted_root_vuid': '2849 1029 3847',
        'nodes': [
          {
            'vuid': '284910293847',
            'formatted_vuid': '2849 1029 3847',
            'name': 'Aarav Sharma',
            'gender': 'Male',
            'dob': '1998-05-18',
            'category': 'GEN',
            'is_verified': true,
            'is_claimed': true,
            'status': 'Active',
          },
          {
            'vuid': '928174019284',
            'formatted_vuid': '9281 7401 9284',
            'name': 'Pooja Sharma',
            'gender': 'Female',
            'dob': '2000-09-22',
            'category': 'GEN',
            'is_verified': true,
            'is_claimed': true,
            'status': 'Active',
          }
        ],
        'edges': [
          {
            'source': '284910293847',
            'target': '928174019284',
            'type': 'Spouse',
            'status': 'Mutual_Confirmed',
          }
        ]
      };

      final graph = TreeGraphData.fromJson(json);

      expect(graph.rootVuid, '284910293847');
      expect(graph.formattedRootVuid, '2849 1029 3847');
      expect(graph.nodes.length, 2);
      expect(graph.edges.length, 1);
      expect(graph.nodes[0].name, 'Aarav Sharma');
      expect(graph.nodes[1].name, 'Pooja Sharma');
      expect(graph.edges[0].type, 'Spouse');
    });
  });
}
