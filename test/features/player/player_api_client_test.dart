import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solo_leveling_calisthenics/features/player/data/player_api_client.dart';

void main() {
  group('PlayerApiClient auth headers', () {
    test('fetchPlayerJson sends bearer token when session is available', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, Object?>{
            'player': <String, Object?>{},
            'completedDays': 0,
            'stage': <String, Object?>{'index': 1},
          }),
          200,
        );
      });

      final apiClient = PlayerApiClient(
        baseUrl: 'https://example.com',
        accessToken: 'session-token-123',
        httpClient: client,
        disposeHttpClient: false,
      );

      await apiClient.fetchPlayerJson();

      expect(capturedRequest.headers['Authorization'], 'Bearer session-token-123');
    });

    test('updatePlayerProgress sends bearer token when session is available', () async {
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      });

      final apiClient = PlayerApiClient(
        baseUrl: 'https://example.com',
        accessToken: 'session-token-456',
        httpClient: client,
        disposeHttpClient: false,
      );

      await apiClient.updatePlayerProgress(<String, dynamic>{'avatarUrl': ''});

      expect(capturedRequest.headers['Authorization'], 'Bearer session-token-456');
      expect(capturedRequest.headers['Content-Type'], 'application/json');
    });
  });
}
