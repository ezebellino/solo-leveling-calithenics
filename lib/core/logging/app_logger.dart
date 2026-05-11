import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger();

  Map<String, Object?> buildRecord({
    required LogLevel level,
    required String action,
    required String feature,
    required String source,
    required String outcome,
    String? entityId,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    return <String, Object?>{
      'level': level.name,
      'feature': feature,
      'action': action,
      'source': source,
      'entityId': entityId,
      'outcome': outcome,
      ...context,
    }..removeWhere((key, value) => value == null);
  }

  void sync({
    required String feature,
    required String action,
    required String source,
    required String outcome,
    String? entityId,
    LogLevel level = LogLevel.info,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    final record = buildRecord(
      level: level,
      action: action,
      feature: feature,
      source: source,
      entityId: entityId,
      outcome: outcome,
      context: context,
    );
    log(
      level: level,
      event: '${feature}_$action',
      source: source,
      context: record,
    );
  }

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
    final sanitizedContext = <String, Object?>{
      for (final entry in context.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    debugPrint('[${level.name}] $source::$event $sanitizedContext');
  }
}
