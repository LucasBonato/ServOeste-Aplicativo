import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_config.dart';

/// Lazy registry of the application's metric instruments.
abstract final class OtelMetrics {
  static Meter get _meter => OTel.meter(OtelConfig.serviceName);

  static APIHistogram<double>? _httpClientRequestDuration;
  static APIHistogram<double> get httpClientRequestDuration =>
      _httpClientRequestDuration ??= _meter.createHistogram<double>(
        name: 'http.client.request.duration',
        unit: 'ms',
        description: 'Duration of outgoing HTTP requests',
      );

  static APICounter<int>? _httpClientRequestCount;
  static APICounter<int> get httpClientRequestCount =>
      _httpClientRequestCount ??= _meter.createCounter<int>(
        name: 'http.client.request.count',
        unit: '{request}',
        description: 'Number of outgoing HTTP requests',
      );

  static APIUpDownCounter<int>? _httpClientInFlightRequests;
  static APIUpDownCounter<int> get httpClientInFlightRequests =>
      _httpClientInFlightRequests ??= _meter.createUpDownCounter<int>(
        name: 'http.client.in_flight_requests',
        unit: '{request}',
        description: 'HTTP requests currently in flight',
      );

  static APICounter<int>? _authLoginAttempts;
  static APICounter<int> get authLoginAttempts =>
      _authLoginAttempts ??= _meter.createCounter<int>(
        name: 'auth.login.attempts',
        unit: '{attempt}',
        description: 'Login attempts',
      );

  static APICounter<int>? _authLoginFailures;
  static APICounter<int> get authLoginFailures =>
      _authLoginFailures ??= _meter.createCounter<int>(
        name: 'auth.login.failures',
        unit: '{failure}',
        description: 'Failed login attempts',
      );

  /// Records request count and duration with standard HTTP attributes.
  static void recordHttpRequest({
    required String method,
    required int statusCode,
    required Duration duration,
    required String serverAddress,
  }) {
    final Map<String, Object> attributes = {
      'http.request.method': method,
      'http.response.status_code': statusCode,
      'server.address': serverAddress,
    };
    httpClientRequestCount.addWithMap(1, attributes);
    httpClientRequestDuration.recordWithMap(
      duration.inMicroseconds / 1000.0,
      attributes,
    );
  }
}
