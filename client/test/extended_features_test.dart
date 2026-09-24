import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanshasetu/core/network/api_client.dart';
import 'package:vanshasetu/features/auth/providers/auth_provider.dart';
import 'package:vanshasetu/features/analytics/screens/demographics_screen.dart';
import 'package:vanshasetu/features/matrimony/screens/matrimony_search_screen.dart';
import 'package:vanshasetu/features/audit/screens/audit_logs_screen.dart';

class MockApiClient extends ApiClient {
  final Map<String, dynamic> Function(String url)? onGet;
  final Map<String, dynamic> Function(String url, Map<String, dynamic> body)? onPost;

  MockApiClient({this.onGet, this.onPost});

  @override
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? extraHeaders}) async {
    if (onGet != null) return onGet!(url);
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
  }) async {
    if (onPost != null) return onPost!(url, body);
    return {};
  }
}

void main() {
  group('Extended Sovereign & Civil Features Widget Tests', () {
    testWidgets('DemographicsScreen: Renders demographics analytics dashboard and population metrics', (WidgetTester tester) async {
      final mockClient = MockApiClient(
        onGet: (url) {
          return {
            'total_population': 1250,
            'gender_distribution': {'male': 650, 'female': 590, 'other': 10},
            'age_distribution': {
              'children_0_14': 250,
              'youth_15_24': 300,
              'adults_25_59': 550,
              'seniors_60_plus': 150,
            },
            'social_categories': {
              'GEN': 450,
              'OBC': 500,
              'SC': 180,
              'ST': 80,
              'EWS': 40,
            },
            'digital_adoption': {'claimed_count': 1200, 'claimed_percentage': '96.0'},
          };
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: const MaterialApp(
            home: DemographicsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('National Demographic & Census Analytics'), findsOneWidget);
      expect(find.text('Demographic Filter Criteria'), findsOneWidget);

      // Verify Metrics and Filters
      expect(find.text('TOTAL FILTERED POPULATION'), findsOneWidget);
      expect(find.text('1250 Citizens'), findsOneWidget);
      expect(find.text('96.0% Claimed & OCP Verified'), findsOneWidget);

      // Verify Gender & Age distribution titles
      expect(find.text('Gender Ratio Distribution'), findsOneWidget);
      expect(find.text('Age Demographics Pyramid'), findsOneWidget);
      expect(find.text('Social Category Breakdown'), findsOneWidget);

      // Verify Specific Stats
      expect(find.text('Male (पुरुष)'), findsOneWidget);
      expect(find.text('Female (महिला)'), findsOneWidget);
      expect(find.text('Children (0 - 14 yrs)'), findsOneWidget);
      expect(find.text('General (GEN)'), findsOneWidget);
    });

    testWidgets('MatrimonySearchScreen: Renders Gotra exogamy & bride-groom search engine', (WidgetTester tester) async {
      final mockClient = MockApiClient(
        onPost: (url, body) {
          return {
            'success': true,
            'seeker_gotra': 'Bharadwaj',
            'match_count': 2,
            'candidates': [
              {
                'vuid': '910283746501',
                'formatted_vuid': '9102 8374 6501',
                'full_name': 'Priya Sharma',
                'gender': 'Female',
                'dob': '1997-04-18',
                'age': 29,
                'height_cm': 165,
                'gotra': 'Kashyap',
                'gotra_status': 'Permitted_Exogamous',
                'is_sagotra': false,
                'religion': 'Hindu',
                'marital_status': 'Single',
                'blood_group': 'B+',
                'state': 'Madhya Pradesh',
                'district': 'Indore',
                'caste': 'Brahmin',
                'category': 'GEN',
                'is_ocp_verified': true,
                'education': {
                  'qualification_level': 'Postgraduate',
                  'degree_name': 'M.Tech in AI',
                  'institution': 'IIT Indore',
                  'occupation_sector': 'IT / Software',
                  'profession_title': 'Principal ML Engineer',
                },
              },
              {
                'vuid': '910283746502',
                'formatted_vuid': '9102 8374 6502',
                'full_name': 'Sunita Verma',
                'gender': 'Female',
                'dob': '1998-11-22',
                'age': 27,
                'height_cm': 160,
                'gotra': 'Bharadwaj',
                'gotra_status': 'Warning_Sagotra',
                'is_sagotra': true,
                'religion': 'Hindu',
                'marital_status': 'Single',
                'blood_group': 'O+',
                'state': 'Madhya Pradesh',
                'district': 'Bhopal',
                'caste': 'Verma',
                'category': 'OBC',
                'is_ocp_verified': false,
                'education': null,
              }
            ],
          };
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: const MaterialApp(
            home: MatrimonySearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('VanshaSetu Matrimony & Lineage Match'), findsOneWidget);

      // Verify Candidates
      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Sunita Verma'), findsOneWidget);

      // Verify Gotra Exogamy badges
      expect(find.text('✅ Exogamous Match (विवाह योग्य)'), findsOneWidget);
      expect(find.text('⚠️ Sagotra Alert (सगोत्र)'), findsOneWidget);

      // Verify Education details display
      expect(find.text('M.Tech in AI • Principal ML Engineer'), findsOneWidget);
    });

    testWidgets('AuditLogsScreen: Renders HIPAA § 164.312(b) tamper-proof audit trail', (WidgetTester tester) async {
      final mockClient = MockApiClient(
        onGet: (url) {
          if (url.contains('verify-integrity')) {
            return {
              'success': true,
              'tamper_free': true,
              'chain_valid': true,
            };
          }
          return {
            'success': true,
            'total': 2,
            'logs': [
              {
                'id': 1,
                'actor_vuid': 'CIVIL_OFFICER_01',
                'action': 'BIRTH_REGISTRATION',
                'resource_type': 'CITIZEN_RECORD',
                'resource_id': '100000000005',
                'ip_address': '127.0.0.1',
                'status': 'SUCCESS',
                'created_at': '2026-09-24T10:00:00.000Z',
                'log_hash': 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
              },
              {
                'id': 2,
                'actor_vuid': 'CIVIL_OFFICER_01',
                'action': 'MARRIAGE_REGISTRATION',
                'resource_type': 'MARRIAGE_CERTIFICATE',
                'resource_id': 'MAR-2026-9901',
                'ip_address': '127.0.0.1',
                'status': 'SUCCESS',
                'created_at': '2026-09-24T10:05:00.000Z',
                'log_hash': 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
              },
            ],
          };
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(mockClient),
          ],
          child: const MaterialApp(
            home: AuditLogsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header and Hash Chain Banner
      expect(find.text('Immutable HIPAA Audit Trail'), findsOneWidget);
      expect(find.text('HIPAA § 164.312(b) SHA-256 Hash Chain: INTACT (100% Tamper-Free)'), findsOneWidget);

      // Verify Action log badges and resources
      expect(find.text('BIRTH_REGISTRATION'), findsOneWidget);
      expect(find.text('MARRIAGE_REGISTRATION'), findsOneWidget);
      expect(find.text('Actor: CIVIL_OFFICER_01  |  Target: CITIZEN_RECORD (100000000005)'), findsOneWidget);
      expect(find.text('Actor: CIVIL_OFFICER_01  |  Target: MARRIAGE_CERTIFICATE (MAR-2026-9901)'), findsOneWidget);
    });
  });
}
