/// Central configuration for OpenTelemetry instrumentation.
///
/// Overridable at build/run time via `--dart-define`:
/// - `OTEL_EXPORTER_OTLP_ENDPOINT`: OTLP/HTTP endpoint
/// - `OTEL_TRACES_SAMPLER`: trace sampling strategy
///   (always_on/always_off/traceidratio/parentbased_traceidratio)
/// - `OTEL_TRACES_SAMPLER_RATIO`: sampling ratio for `traceidratio`
///   and `parentbased_traceidratio` (0.0-1.0)
/// - `OTEL_LOG_LEVEL`: minimum severity for exported log records
///   (trace/debug/info|information/warn|warning/error/fatal/none; '' = all)
/// - `OTEL_LOG_PRINT`: capture `print()` calls as OTel logs
library;

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

abstract final class OtelConfig {
  static const String serviceName = 'serv-oeste-app';
  static const String serviceVersion = '1.0.0';

  static const String endpoint = String.fromEnvironment(
    'OTEL_EXPORTER_OTLP_ENDPOINT',
    defaultValue: 'http://localhost:4318',
  );

  static const String sampler = String.fromEnvironment(
    'OTEL_TRACES_SAMPLER',
    defaultValue: 'always_on',
  );

  static const String samplerRatio = String.fromEnvironment(
    'OTEL_TRACES_SAMPLER_RATIO',
    defaultValue: '1.0',
  );

  static const String logLevel = String.fromEnvironment(
    'OTEL_LOG_LEVEL',
    defaultValue: '',
  );

  static const bool logPrint = bool.fromEnvironment(
    'OTEL_LOG_PRINT',
    defaultValue: true,
  );

  /// Trace sampler built from the `OTEL_TRACES_SAMPLER` dart-define.
  static Sampler get samplerInstance {
    final double ratio = double.tryParse(samplerRatio) ?? 1.0;
    switch (sampler.toLowerCase()) {
      case 'always_off':
        return const AlwaysOffSampler();
      case 'traceidratio':
        return TraceIdRatioSampler(ratio);
      case 'parentbased_traceidratio':
        return ParentBasedSampler(TraceIdRatioSampler(ratio));
      case 'parentbased':
      case 'parentbased_always_on':
        return ParentBasedSampler(const AlwaysOnSampler());
      default:
        return const AlwaysOnSampler();
    }
  }

  /// Minimum OTel severity number accepted for exported log records.
  ///
  /// Records below this threshold are dropped by [AppLogger]. Mirrors the
  /// OpenTelemetry severity scale: TRACE=1, DEBUG=5, INFO=9, WARN=13,
  /// ERROR=17, FATAL=21. NONE (0) suppresses everything but exceptions.
  static int get minSeverityNumber {
    switch (logLevel.toLowerCase()) {
      case 'trace':
        return 1;
      case 'debug':
        return 5;
      case 'info':
      case 'information':
        return 9;
      case 'warn':
      case 'warning':
        return 13;
      case 'error':
        return 17;
      case 'fatal':
        return 21;
      case 'none':
        return 0;
      default:
        return 1;
    }
  }
}
