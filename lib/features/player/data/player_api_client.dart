import 'dart:convert';

import 'package:http/http.dart' as http;

class PlayerApiClient {
  static const bootstrapContractVersion = '2026-05-10.player-bootstrap.v1';

  PlayerApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    bool disposeHttpClient = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _disposeHttpClient = httpClient == null ? true : disposeHttpClient;

  final String baseUrl;
  final http.Client _httpClient;
  final bool _disposeHttpClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> fetchBootstrapJson() {
    return _getJson('/api/v1/bootstrap');
  }

  Future<Map<String, dynamic>> fetchPlayerJson() {
    return _getJson('/api/v1/player');
  }

  Future<void> updatePlayerProgress(Map<String, dynamic> payload) async {
    final response = await _httpClient.patch(
      _uri('/api/v1/player/progress'),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'No se pudo actualizar el progreso remoto del jugador.',
        _uri('/api/v1/player/progress'),
      );
    }
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _httpClient.get(_uri(path));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'No se pudo obtener $path.',
        _uri(path),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('La respuesta no es un objeto JSON.');
    }
    return decoded;
  }

  void dispose() {
    if (_disposeHttpClient) {
      _httpClient.close();
    }
  }
}
