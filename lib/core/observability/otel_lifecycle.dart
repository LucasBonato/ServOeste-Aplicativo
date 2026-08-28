import 'dart:ui' show AppExitResponse;

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';

/// Flushes and shuts down the OpenTelemetry SDK when the app exits so
/// queued telemetry is not lost.
class OtelLifecycle extends StatefulWidget {
  final Widget child;

  const OtelLifecycle({super.key, required this.child});

  @override
  State<OtelLifecycle> createState() => _OtelLifecycleState();
}

class _OtelLifecycleState extends State<OtelLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onExitRequested: _shutdown);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<AppExitResponse> _shutdown() async {
    await OTel.tracerProvider().shutdown();
    await OTel.meterProvider().shutdown();
    await OTel.loggerProvider().shutdown();
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
