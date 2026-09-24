import 'package:flutter_test/flutter_test.dart';
import 'package:vanshasetu/core/network/api_client.dart';
import 'package:vanshasetu/core/constants/api_endpoints.dart';

void main() {
  group('ApiClient & Network Exception Tests', () {
    test('ApiException: Formats status code and message correctly', () {
      final exception = ApiException(
        statusCode: 400,
        message: 'Missing mandatory registration fields.',
        details: {'field': 'first_name'},
      );

      expect(exception.statusCode, 400);
      expect(exception.message, 'Missing mandatory registration fields.');
      expect(exception.toString(), 'ApiException (HTTP 400): Missing mandatory registration fields.');
    });

    test('ApiEndpoints: Generates valid endpoint URIs', () {
      expect(ApiEndpoints.citizenRegister, contains('/api/v1/citizen/register'));
      expect(ApiEndpoints.kinshipConnect, contains('/api/v1/kinship/connect'));
      expect(ApiEndpoints.docVerifyOcp, contains('/api/v1/docs/verify-ocp'));
      expect(ApiEndpoints.citizenFetch('109284729102'), contains('/api/v1/citizen/109284729102'));
      expect(ApiEndpoints.treeFetch('109284729102'), contains('/api/v1/tree/109284729102'));
      expect(ApiEndpoints.sirConflicts, contains('/api/v1/sir/conflicts'));
      expect(ApiEndpoints.health, contains('/health'));
    });

    test('ApiClient: Constructor instantiates with custom secret', () {
      final client = ApiClient(hmacSecret: 'CUSTOM_TEST_SECRET');
      expect(client, isNotNull);
      client.close();
    });

    test('ApiException: Handles non-JSON error messages gracefully', () {
      final exception = ApiException(
        statusCode: 502,
        message: '502 Bad Gateway',
        details: {'error': '<html>502 Bad Gateway</html>'},
      );

      expect(exception.statusCode, 502);
      expect(exception.message, contains('502 Bad Gateway'));
      expect(exception.details['error'], contains('<html>'));
    });
  });
}
