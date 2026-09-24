import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Determine appropriate base URL depending on host platform
  static String get baseUrl {
    if (const bool.hasEnvironment('API_URL')) {
      return const String.fromEnvironment('API_URL');
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000'; // Standard Android loopback
    }
    return 'http://127.0.0.1:3000'; // iOS Simulator & Desktop
  }

  // Endpoints
  static String get citizenRegister => '$baseUrl/api/v1/citizen/register';
  static String citizenFetch(String vuid) => '$baseUrl/api/v1/citizen/$vuid';
  static String get kinshipConnect => '$baseUrl/api/v1/kinship/connect';
  static String get docVerifyOcp => '$baseUrl/api/v1/docs/verify-ocp';
  static String treeFetch(String vuid) => '$baseUrl/api/v1/tree/$vuid';
  static String get sirConflicts => '$baseUrl/api/v1/sir/conflicts';
  static String get health => '$baseUrl/health';

  // Life Events & Civil Registry
  static String get eventBirth => '$baseUrl/api/v1/events/birth';
  static String get eventDeath => '$baseUrl/api/v1/events/death';
  static String get eventMarriage => '$baseUrl/api/v1/events/marriage';

  // Education & Occupation
  static String get educationAdd => '$baseUrl/api/v1/education/add';
  static String educationFetch(String vuid) => '$baseUrl/api/v1/education/$vuid';

  // Indian Matrimony Search
  static String get matrimonySearch => '$baseUrl/api/v1/matrimony/search';

  // Filtered Demographics & Population Analytics
  static String get analyticsDemographics => '$baseUrl/api/v1/analytics/demographics';

  // Immutable HIPAA Audit Trail
  static String get auditLogs => '$baseUrl/api/v1/audit/logs';
  static String get auditVerifyIntegrity => '$baseUrl/api/v1/audit/verify-integrity';
}
