import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';

class InventoryRemoteSnapshot {
  const InventoryRemoteSnapshot({
    required this.items,
    required this.contractVersion,
  });

  final Map<String, int> items;
  final String contractVersion;
}

class InventoryApiClient {
  static const contractVersion = '2026-05-11.inventory.v1';

  InventoryApiClient({
    required this.baseUrl,
    this.accessToken,
    http.Client? httpClient,
    bool disposeHttpClient = true,
  })  : _httpClient = httpClient ?? http.Client(),
        _disposeHttpClient = httpClient == null ? true : disposeHttpClient;

  final String baseUrl;
  final String? accessToken;
  final http.Client _httpClient;
  final bool _disposeHttpClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _authHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  Future<InventoryRemoteSnapshot> fetchInventory() async {
    final response = await _httpClient.get(_uri('/api/v1/inventory'), headers: _authHeaders);
    final json = _decodeObjectResponse(
      response,
      fallbackCode: 'inventory_refresh_failed',
      fallbackMessage: 'No se pudo obtener el inventario remoto.',
    );
    final itemsJson = json['items'];
    final syncJson = json['sync'];
    if (itemsJson is! List<dynamic> || syncJson is! Map<String, dynamic>) {
      throw const FormatException('La respuesta de inventario es invalida.');
    }

    return InventoryRemoteSnapshot(
      items: itemsJson.cast<Map<String, dynamic>>().fold<Map<String, int>>(
        <String, int>{},
        (items, item) {
          items[_inventoryCodeToLocal(item['code'] as String)] =
              item['quantity'] as int? ?? 0;
          return items;
        },
      ),
      contractVersion: syncJson['contractVersion'] as String? ?? contractVersion,
    );
  }

  Future<InventoryRemoteSnapshot> syncInventory(Map<String, int> items) async {
    final response = await _httpClient.patch(
      _uri('/api/v1/inventory/sync'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        ..._authHeaders,
      },
      body: jsonEncode(<String, Object?>{
        'items': items.entries
            .map(
              (entry) => <String, Object?>{
                'code': _inventoryCodeToRemote(entry.key),
                'quantity': entry.value,
              },
            )
            .toList(growable: false),
      }),
    );
    final json = _decodeObjectResponse(
      response,
      fallbackCode: 'inventory_sync_failed',
      fallbackMessage: 'No se pudo sincronizar el inventario remoto.',
    );
    final itemsJson = json['items'];
    final syncJson = json['sync'];
    if (itemsJson is! List<dynamic> || syncJson is! Map<String, dynamic>) {
      throw const FormatException('La respuesta de sincronizacion de inventario es invalida.');
    }

    return InventoryRemoteSnapshot(
      items: itemsJson.cast<Map<String, dynamic>>().fold<Map<String, int>>(
        <String, int>{},
        (normalized, item) {
          normalized[_inventoryCodeToLocal(item['code'] as String)] =
              item['quantity'] as int? ?? 0;
          return normalized;
        },
      ),
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

  String _inventoryCodeToLocal(String code) {
    switch (code) {
      case 'streak_freeze':
        return 'freeze';
      case 'quest_reroll':
        return 'reroll';
      default:
        return code;
    }
  }

  String _inventoryCodeToRemote(String code) {
    switch (code) {
      case 'freeze':
        return 'streak_freeze';
      case 'reroll':
        return 'quest_reroll';
      default:
        return code;
    }
  }

  void dispose() {
    if (_disposeHttpClient) {
      _httpClient.close();
    }
  }
}
