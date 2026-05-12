import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';
import '../domain/auth_provider_option.dart';
import '../domain/auth_session.dart';
import '../domain/magic_link_request_result.dart';

class AuthApiClient {
  AuthApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    bool disposeHttpClient = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _disposeHttpClient = httpClient == null ? true : disposeHttpClient;

  final String baseUrl;
  final http.Client _httpClient;
  final bool _disposeHttpClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<AuthProviderOption>> fetchProviders() async {
    final response = await _httpClient.get(_uri('/api/v1/auth/providers'));
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_providers_failed',
      fallbackMessage: 'No se pudieron cargar los proveedores de acceso.',
    );

    final decoded = _decodeObject(response.body);
    final providersJson = decoded['providers'];
    if (providersJson is! List) {
      throw const FormatException('Missing providers list.');
    }

    return providersJson
        .map((entry) => _providerFromJson(Map<String, dynamic>.from(entry as Map)))
        .toList(growable: false);
  }

  Future<AuthSession> exchangeGoogle({
    required String email,
    required String displayName,
    required String providerSubject,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/google'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, Object?>{
        'idToken': 'dev-google-token',
        'email': email,
        'displayName': displayName,
        'providerSubject': providerSubject,
        'avatarUrl': '',
      }),
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_google_failed',
      fallbackMessage: 'No se pudo iniciar sesion con Google.',
    );
    return _issuedSessionFromJson(_decodeObject(response.body));
  }

  Future<MagicLinkRequestResult> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/magic-link/request'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, Object?>{
        'email': email,
        'displayName': displayName,
        'redirectUrl': redirectUrl,
      }..removeWhere((key, value) => value == null || (value is String && value.isEmpty))),
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_magic_link_request_failed',
      fallbackMessage: 'No se pudo solicitar el magic link.',
    );

    final decoded = _decodeObject(response.body);
    return MagicLinkRequestResult(
      email: email,
      expiresAt: DateTime.parse(decoded['expiresAt'] as String),
      delivery: decoded['delivery'] as String? ?? 'accepted',
      previewMode: decoded['previewMode'] as bool? ?? false,
      previewToken: decoded['previewToken'] as String?,
      verificationUrl: decoded['verificationUrl'] as String?,
    );
  }

  Future<AuthSession> verifyMagicLink({
    required String token,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/magic-link/verify'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, Object?>{'token': token}),
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_magic_link_verify_failed',
      fallbackMessage: 'No se pudo verificar el magic link.',
    );
    return _issuedSessionFromJson(_decodeObject(response.body));
  }

  Future<AuthSession> fetchCurrentSession({
    required String accessToken,
  }) async {
    final response = await _httpClient.get(
      _uri('/api/v1/auth/session'),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_session_failed',
      fallbackMessage: 'No se pudo restaurar la sesion actual.',
    );

    final decoded = _decodeObject(response.body);
    final userJson = Map<String, dynamic>.from(decoded['user'] as Map);
    return AuthSession(
      accessToken: accessToken,
      provider: decoded['provider'] as String? ?? '',
      expiresAt: DateTime.parse(decoded['expiresAt'] as String),
      userId: userJson['id'] as String? ?? '',
      displayName: userJson['displayName'] as String? ?? '',
      avatarUrl: userJson['avatarUrl'] as String? ?? '',
      email: userJson['email'] as String?,
      sessionId: decoded['sessionId'] as String?,
    );
  }

  Future<void> logout({
    required String accessToken,
  }) async {
    final response = await _httpClient.post(
      _uri('/api/v1/auth/logout'),
      headers: <String, String>{'Authorization': 'Bearer $accessToken'},
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'auth_logout_failed',
      fallbackMessage: 'No se pudo cerrar la sesion.',
    );
  }

  AuthProviderOption _providerFromJson(Map<String, dynamic> json) {
    return AuthProviderOption(
      code: json['code'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      transport: json['transport'] as String? ?? '',
      availability: json['availability'] as String? ?? 'unknown',
      statusMessage: json['statusMessage'] as String?,
      requiresManualCompletion:
          json['requiresManualCompletion'] as bool? ?? false,
    );
  }

  AuthSession _issuedSessionFromJson(Map<String, dynamic> json) {
    final userJson = Map<String, dynamic>.from(json['user'] as Map);
    return AuthSession(
      accessToken: json['accessToken'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: userJson['id'] as String? ?? '',
      displayName: userJson['displayName'] as String? ?? '',
      avatarUrl: userJson['avatarUrl'] as String? ?? '',
      email: userJson['email'] as String?,
    );
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no es un objeto JSON.');
    }
    return decoded;
  }

  void _throwIfRequestFailed(
    http.Response response, {
    required String fallbackCode,
    required String fallbackMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final errorJson = decoded['error'];
        if (errorJson is Map<String, dynamic>) {
          final code = errorJson['code'];
          final message = errorJson['message'];
          final requestId = errorJson['requestId'];
          if (code is String && message is String) {
            throw AppException(
              code,
              message,
              isRetryable: response.statusCode >= 500,
              logContext: <String, Object?>{
                'requestId': requestId,
                'statusCode': response.statusCode,
              },
            );
          }
        }
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
    }

    throw AppException(
      fallbackCode,
      fallbackMessage,
      isRetryable: response.statusCode >= 500,
      logContext: <String, Object?>{
        'statusCode': response.statusCode,
      },
    );
  }

  void dispose() {
    if (_disposeHttpClient) {
      _httpClient.close();
    }
  }
}
