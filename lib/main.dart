import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:route_flow/app/app.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:route_flow/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (AppConfig.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = AppConfig.isDev ? 'development' : 'production';
      },
      appRunner: () => _initializeAppAndRun(),
    );
  } else {
    debugPrint('[Main] Sentry DSN missing. Monitoring is disabled.');
    await _initializeAppAndRun();
  }
}

Future<void> _initializeAppAndRun() async {
  try {
    await Hive.initFlutter();
    
    // Fail-fast configuration check
    AppConfig.validate();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    
    // Dependency Injection initialization
    await configureDependencies();

    // Setup global error capture
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };

    runApp(const RouteFlowApp());
  } catch (e, stack) {
    debugPrint('[Critical Error during startup]: $e');
    if (AppConfig.sentryDsn.isNotEmpty) {
      await Sentry.captureException(e, stackTrace: stack);
    }
  }
}
