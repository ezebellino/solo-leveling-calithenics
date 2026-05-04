import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger();

  void debug({
    required String event,
    String source = 'app',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    log(level: LogLevel.debug, event: event, source: source, context: context);
  }

  void info({
    required String event,
    String source = 'app',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    log(level: LogLevel.info, event: event, source: source, context: context);
  }

  void warning({
    required String event,
    String source = 'app',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    log(level: LogLevel.warning, event: event, source: source, context: context);
  }

  void error({
    required String event,
    String source = 'app',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    log(level: LogLevel.error, event: event, source: source, context: context);
  }

  void log({
    required LogLevel level,
    required String event,
    String source = 'app',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    debugPrint('[${level.name}] $source::$event $context');
  }
}
