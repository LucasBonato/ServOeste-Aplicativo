import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_config.dart';

/// Thin facade over the OpenTelemetry logger.
///
/// Every log record automatically carries the trace/span ids of the
/// currently active span, so logs are correlated with traces in the
/// dashboard.
///
/// The `OTEL_LOG_LEVEL` dart-define (see [OtelConfig]) filters records at
/// the caller: `trace`/`debug`/`info`/`warn`/`error` calls below the
/// configured minimum severity are dropped before reaching the SDK.
/// [exception] is never filtered.
abstract final class AppLogger {
  static OTelLogger get _otel => OTel.logger(OtelConfig.serviceName);

  static bool _enabled(int severityNumber) =>
      severityNumber >= OtelConfig.minSeverityNumber;

  static Attributes? _attrs(Map<String, Object>? attributes) {
    if (attributes == null || attributes.isEmpty) return null;
    return OTel.attributesFromMap(attributes);
  }

  static void trace(
    dynamic body, {
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    if (!_enabled(1)) return;
    _otel.trace(body, attributes: _attrs(attributes), eventName: eventName);
  }

  static void debug(
    dynamic body, {
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    if (!_enabled(5)) return;
    _otel.debug(body, attributes: _attrs(attributes), eventName: eventName);
  }

  static void info(
    dynamic body, {
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    if (!_enabled(9)) return;
    _otel.info(body, attributes: _attrs(attributes), eventName: eventName);
  }

  static void warn(
    dynamic body, {
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    if (!_enabled(13)) return;
    _otel.warn(body, attributes: _attrs(attributes), eventName: eventName);
  }

  static void error(
    dynamic body, {
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    if (!_enabled(17)) return;
    _otel.error(body, attributes: _attrs(attributes), eventName: eventName);
  }

  /// Emits an error log record for an exception using the standard
  /// `exception.*` attributes. Never filtered by `OTEL_LOG_LEVEL`.
  static void exception(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object>? attributes,
    String? eventName,
  }) {
    _otel.error(
      error.toString(),
      attributes: OTel.attributesFromMap({
        'exception.type': error.runtimeType.toString(),
        'exception.message': error.toString(),
        if (stackTrace != null) 'exception.stacktrace': stackTrace.toString(),
        ...?attributes,
      }),
      eventName: eventName,
    );
  }
}