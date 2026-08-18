import 'dart:convert';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

/// Helpers for span management and trace context propagation.
abstract final class Tracing {
  /// User id of the authenticated user, propagated on outgoing requests
  /// and attached to client spans.
  static String? currentUserId;

  static Tracer get _tracer => OTel.tracer();

  /// Runs [fn] inside a new span.
  ///
  /// The span is ended automatically when [fn] completes. Exceptions thrown
  /// by [fn] are recorded on the span (status set to error) and rethrown.
  /// The authenticated user id is attached as `enduser.id` on every span.
  static Future<T> trace<T>(
    String name, {
    required Future<T> Function() fn,
    SpanKind kind = SpanKind.internal,
    Map<String, Object>? attributes,
  }) {
    final String? userId = currentUserId;
    final Map<String, Object> effectiveAttributes = <String, Object>{
      if (userId != null && userId.isNotEmpty) 'enduser.id': userId,
      ...?attributes,
    };
    return _tracer.startActiveSpanAsync(
      name: name,
      kind: kind,
      attributes: effectiveAttributes.isEmpty
          ? null
          : OTel.attributesFromMap(effectiveAttributes),
      fn: (_) => fn(),
    );
  }
  /// Builds a bloc operation span name from an event type,
  /// e.g. TecnicoSearchEvent -> bloc.tecnico.search.
  static String spanNameFromEvent(Type type) {
    final String name = type.toString();
    final String withoutSuffix =
        name.endsWith('Event') ? name.substring(0, name.length - 5) : name;
    return 'bloc.${_camelToDots(withoutSuffix)}';
  }

  static String _camelToDots(String value) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final String char = value[i];
      if (char == '_') {
        buffer.write('.');
      } else if (RegExp('[A-Z]').hasMatch(char)) {
        if (i > 0) buffer.write('.');
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Injects the trace context carried by [context] (`traceparent`, `tracestate`,
  /// `baggage`) into [headers] so the backend can join the trace.
  static void injectPropagationFrom(
    Context context,
    Map<String, dynamic> headers,
  ) {
    final Map<String, String> carrier = <String, String>{};
    OTelAPI.textMapPropagator.inject(
      context,
      carrier,
      _MapSetter(carrier),
    );
    final String? userId = currentUserId;
    if (userId != null && userId.isNotEmpty) {
      final String? existing = carrier['baggage'];
      carrier['baggage'] = (existing == null || existing.isEmpty)
          ? 'user.id=$userId'
          : '$existing,user.id=$userId';
    }
    headers.addAll(carrier);
  }

  /// Extracts the `sub` claim from a JWT access token, if present.
  static String? userIdFromJwt(String token) {
    try {
      final List<String> parts = token.split('.');
      if (parts.length != 3) return null;
      final String normalized = base64Url.normalize(parts[1]);
      final Map<String, dynamic> payload = jsonDecode(
        utf8.decode(base64Url.decode(normalized)),
      ) as Map<String, dynamic>;
      return payload['sub']?.toString();
    } catch (_) {
      return null;
    }
  }
}

class _MapSetter implements TextMapSetter<String> {
  final Map<String, String> _carrier;

  _MapSetter(this._carrier);

  @override
  void set(String key, String value) => _carrier[key] = value;
}
