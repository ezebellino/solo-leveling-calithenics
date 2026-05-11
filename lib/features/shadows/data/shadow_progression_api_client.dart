import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';

class ShadowProgressionRemoteSnapshot {
  const ShadowProgressionRemoteSnapshot({
    required this.shadowArmy,
    required this.unlockedShadowIds,
    required this.contractVersion,
  });

  final int shadowArmy;
  final List<String> unlockedShadowIds;
  final String contractVersion;
}

class ShadowProgressionApiClient {
  static const contractVersion = '2026-05-11.shadows.v1';

  ShadowProgressionApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    bool disposeHttpClient = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _disposeHttpClient = httpClient == null ? true : disposeHttpClient;

  final String baseUrl;
  final http.Client _httpClient;
  final bool _disposeHttpClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<ShadowProgressionRemoteSnapshot> fetchProgression() async {
    final response = await _httpClient.get(_uri('/api/v1/shadows/progression'));
    final json = _decodeObjectResponse(
      response,
      fallbackCode: 'shadow_refresh_failed',
      fallbackMessage: 'No se pudo obtener la progresion remota de sombras.',
    );
    return _snapshotFromJson(json);
  }

  Future<ShadowProgressionRemoteSnapshot> syncProgression({
    required int shadowArmy,
    required List<String> unlockedShadowIds,
  }) async {
    final response = await _httpClient.patch(
      _uri('/api/v1/shadows/progression'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, Object?>{
        'shadowArmy': shadowArmy,
        'unlockedShadowIds': unlockedShadowIds,
      }),
    );
    final json = _decodeObjectResponse(
      response,
      fallbackCode: 'shadow_sync_failed',
      fallbackMessage: 'No se pudo sincronizar la progresion remota de sombras.',
    );
    return _snapshotFromJson(json);
  }

  ShadowProgressionRemoteSnapshot _snapshotFromJson(Map<String, dynamic> json) {
    final unlockedJson = json['unlockedShadows'];
    final syncJson = json['sync'];
    if (unlockedJson is! List<dynamic> || syncJson is! Map<String, dynamic>) {
      throw const FormatException('La respuesta de sombras es invalida.');
    }
    return ShadowProgressionRemoteSnapshot(
      shadowArmy: json['shadowArmy'] as int? ?? 0,
      unlockedShadowIds: unlockedJson
          .cast<Map<String, dynamic>>()
          .map((item) => item['code'] as String)
          .toList(growable: false),
      contractVersion: syncJson['contractVersion'] as String? ?? contractVersion,
    );
  }

  Map<String, dynamic> _decodeObjectResponse(
    http.Response response, {
    required String fallbackCode,
    required String fallbackMessage,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwAppExceptionFromResponse(
        response,
        fallbackCode: fallbackCode,
        fallbackMessage: fallbackMessage,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no es un objeto JSON.');
    }
    return decoded;
  }

  void _throwAppExceptionFromResponse(
    http.Response response, {
    required String fallbackCode,
    required String fallbackMessage,
  }) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final errorJson = decoded['error'];
        if (errorJson is Map<String, dynamic>) {
          final code = errorJson['code'];
          final message = errorJson['message'];
          if (code is String && message is String) {
            throw AppException(code, message);
          }
        }
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
    }

    throw AppException(fallbackCode, fallbackMessage);
  }

  void dispose() {
    if (_disposeHttpClient) {
      _httpClient.close();
    }
  }
}
