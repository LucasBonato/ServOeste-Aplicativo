import 'dart:async';

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:serv_oeste/core/di/app_dependencies.dart';
import 'package:serv_oeste/core/navigation/app_navigation_service.dart';
import 'package:serv_oeste/core/navigation/navigation_service.dart';
import 'package:serv_oeste/core/observability/app_logger.dart';
import 'package:serv_oeste/core/observability/otel_config.dart';
import 'package:serv_oeste/core/observability/otel_console.dart'
if (dart.library.js_interop) 'package:serv_oeste/core/observability/otel_console_web.dart';
import 'package:serv_oeste/core/observability/otel_lifecycle.dart';
import 'package:serv_oeste/core/observability/tracing.dart';
import 'package:serv_oeste/core/routing/custom_router.dart';
import 'package:serv_oeste/core/routing/routes.dart';
import 'package:serv_oeste/core/services/flutter_secure_storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  runZonedGuarded(
    () async {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        AppLogger.exception(
          details.exception,
          stackTrace: details.stack,
          attributes: {'exception.context': 'flutter'},
        );
      };
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        AppLogger.exception(
          error,
          stackTrace: stack,
          attributes: {'exception.context': 'platform'},
        );
        return true;
      };

      await OTel.runWithPrintInterceptionAsync(() async {
        WidgetsFlutterBinding.ensureInitialized();

        // Route SDK self-diagnostics to the console outside the
        // print-interception bridge. Otherwise every OTelLog.debug(...)
        // ('[DEBUG] ...' text) becomes an exported INFO-level log record
        // in the dashboard.
        OTelLog.logFunction = otelConsoleLog;

        await OTel.initialize(
          serviceName: OtelConfig.serviceName,
          serviceVersion: OtelConfig.serviceVersion,
          endpoint: OtelConfig.endpoint,
          logPrint: OtelConfig.logPrint,
          sampler: OtelConfig.samplerInstance,
          resourceAttributes: OTel.attributesFromMap({
            'deployment.environment': kReleaseMode ? 'production' : 'development',
          }),
        );
        _applySdkLogLevel();

        final String? storedToken = await FlutterSecureStorageService.readPersistedAccessToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          Tracing.currentUserId = Tracing.userIdFromJwt(storedToken);
        }

        final NavigationService navigationService = AppNavigationService(navigatorKey);
        final AppDependencies dependencies = AppDependencies(navigationService);

        runApp(
          MultiBlocProvider(
            providers: dependencies.buildBlocProviders(),
            child: MultiProvider(
              providers: dependencies.buildProviders(),
              child: OtelLifecycle(
                child: MyApp(navigatorKey: navigatorKey),
              ),
            ),
          ),
        );
      });
    },
    (Object error, StackTrace stackTrace) {
      AppLogger.exception(
        error,
        stackTrace: stackTrace,
        attributes: {'exception.context': 'zone'},
      );
    },
  );
}

void _applySdkLogLevel() {
  switch (OtelConfig.logLevel.toLowerCase()) {
    case 'trace':
      OTelLog.enableTraceLogging();
    case 'debug':
      OTelLog.enableDebugLogging();
    case 'info':
    case 'information':
      OTelLog.enableInfoLogging();
    case 'warn':
    case 'warning':
      OTelLog.enableWarnLogging();
    case 'error':
      OTelLog.enableErrorLogging();
    case 'fatal':
      OTelLog.enableFatalLogging();
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serv-Oeste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: Routes.login,
      onGenerateRoute: (settings) => CustomRouter.onGenerateRoute(settings),
    );
  }
}
