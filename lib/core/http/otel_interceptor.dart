import 'dart:convert';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dio/dio.dart';
import 'package:serv_oeste/core/observability/otel_metrics.dart';
import 'package:serv_oeste/core/observability/tracing.dart';

class OtelInterceptor extends Interceptor {
  static const String _spanKey = 'otel_span';
  static const String _durationKey = 'otel_duration';

  Tracer get _tracer => OTel.tracer();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Tracing.injectPropagation(options.headers);
    OtelMetrics.httpClientInFlightRequests.add(1);

    final String? userId = Tracing.currentUserId;
    final Span span = _tracer.startSpan(
      '${options.method} ${options.path}',
      kind: SpanKind.client,
      attributes: OTel.attributesFromMap({
        Http.httpRequestMethod.key: options.method,
        'server.address': options.uri.host,
        'server.port': options.uri.port,
        'network.protocol.name': options.uri.scheme,
        'url.full': options.uri.toString(),
        'enduser.id': ?userId,
      }),
    );
    options.extra[_spanKey] = span;
    options.extra[_durationKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Object? data = response.data;
    final int? bodySize = switch (data) {
      String value => utf8.encode(value).length,
      List<int> value => value.length,
      _ => null,
    };
    final RequestOptions options = response.requestOptions;
    final Span? span = options.extra[_spanKey] as Span?;
    if (span != null && bodySize != null) {
      span.setIntAttribute('http.response.body.size', bodySize);
    }
    _finish(options, response.statusCode ?? 0);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _finish(err.requestOptions, err.response?.statusCode ?? 0, err: err);
    handler.next(err);
  }

  void _finish(RequestOptions options, int statusCode, {DioException? err}) {
    OtelMetrics.httpClientInFlightRequests.add(-1);

    final Stopwatch? stopwatch = options.extra[_durationKey] as Stopwatch?;
    if (stopwatch != null) {
      stopwatch.stop();
      OtelMetrics.recordHttpRequest(
        method: options.method,
        statusCode: statusCode,
        duration: stopwatch.elapsed,
        serverAddress: options.uri.host,
      );
    }

    final Span? span = options.extra[_spanKey] as Span?;
    if (span == null) return;
    if (statusCode != 0) {
      span.setIntAttribute(Http.httpResponseStatusCode.key, statusCode);
    }
    if (err != null) {
      span.setStringAttribute('error.type', err.type.name);
      span.recordException(err, stackTrace: err.stackTrace);
      span.setStatus(SpanStatusCode.Error, err.message);
    }
    span.end();
  }
}
