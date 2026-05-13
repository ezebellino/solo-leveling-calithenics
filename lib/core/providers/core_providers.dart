import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

final appLoggerProvider = Provider<AppLogger>((ref) => const AppLogger());

final apiBaseUrlProvider = Provider<String>(
  (ref) => 'https://backend-api-sync-v2-production.up.railway.app',
);

final googleClientIdProvider = Provider<String?>(
  (ref) => const String.fromEnvironment('GOOGLE_CLIENT_ID').trim().isEmpty
      ? null
      : const String.fromEnvironment('GOOGLE_CLIENT_ID').trim(),
);

final googleServerClientIdProvider = Provider<String?>(
  (ref) => const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID').trim().isEmpty
      ? null
      : const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID').trim(),
);
