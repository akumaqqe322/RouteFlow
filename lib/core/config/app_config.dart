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
    defaultValue: 'https://router.project-osrm.org',
  );

  static const bool isDev = bool.fromEnvironment(
    'IS_DEV',
    defaultValue: true,
  );

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
