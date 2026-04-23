import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String osrmBaseUrl = String.fromEnvironment(
    'OSRM_BASE_URL',
    defaultValue: 'https://router.project-osrm.org/route/v1/driving',
  );

  static const String revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: '',
  );

  static const String revenueCatApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_API_KEY_ANDROID',
    defaultValue: '',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static const bool isDev = bool.fromEnvironment(
    'IS_DEV',
    defaultValue: true,
  );

  static const bool isDemoMode = bool.fromEnvironment(
    'IS_DEMO_MODE',
    defaultValue: false,
  );

  static const bool enableDemoAuth = bool.fromEnvironment(
    'ENABLE_DEMO_AUTH',
    defaultValue: false,
  );

  static bool get enablePremiumPurchases {
    // Disable purchases on Web or if keys are missing
    if (kIsWeb) return false;
    return revenueCatApiKeyIos.isNotEmpty || revenueCatApiKeyAndroid.isNotEmpty;
  }

  static bool get enableCrashReporting {
    // Disable crash reporting on Web or if DSN is missing
    if (kIsWeb) return false;
    return sentryDsn.isNotEmpty;
  }

  const AppConfig();

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        '\n\n[AppConfig Error]: Missing Supabase Configuration.\n'
        'Ensure you are building with:\n'
        '--dart-define=SUPABASE_URL=YOUR_URL\n'
        '--dart-define=SUPABASE_ANON_KEY=YOUR_KEY\n',
      );
    }
  }
}
