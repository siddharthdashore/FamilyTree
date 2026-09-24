import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException (HTTP $statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final String _hmacSecret;

  ApiClient({
    http.Client? client,
    String? hmacSecret,
  })  : _client = client ?? http.Client(),
        _hmacSecret = hmacSecret ?? 'VANSHA_HMAC_SHARED_SECRET_KEY_PROD_8492';

  // Compute HMAC-SHA256 signature conforming to middleware specification:
  // Formula: HMAC-SHA256(timestamp + ":" + nonce + ":" + body, secret)
  Map<String, String> _buildSecurityHeaders(String body) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = '${Random().nextInt(1000000000)}_${DateTime.now().microsecondsSinceEpoch}';
    final message = '$timestamp:$nonce:$body';
    
    final hmacKey = utf8.encode(_hmacSecret);
    final hmac = Hmac(sha256, hmacKey);
    final signature = hmac.convert(utf8.encode(message)).toString();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Vansha-Signature': signature,
      'X-Vansha-Timestamp': timestamp,
      'X-Vansha-Nonce': nonce,
    };
  }

  Future<Map<String, dynamic>> get(String url, {Map<String, String>? extraHeaders}) async {
    try {
      final headers = {
        'Accept': 'application/json',
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network connection failure: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final bodyString = jsonEncode(body);
      final securityHeaders = _buildSecurityHeaders(bodyString);
      
      final headers = {
        ...securityHeaders,
        if (extraHeaders != null) ...extraHeaders,
      };

      final response = await _client
          .post(Uri.parse(url), headers: headers, body: bodyString)
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(statusCode: 0, message: 'Network connection failure: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      body = {'error': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }

    final errorMessage = body is Map && body['message'] != null
        ? body['message']
        : (body is Map && body['error'] != null ? body['error'] : 'HTTP Error ${response.statusCode}');

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage.toString(),
      details: body,
    );
  }

  void close() {
    _client.close();
  }
}
