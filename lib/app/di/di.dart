import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_flow/app/di/di.config.dart';

final getIt = GetIt.instance;

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async => getIt.init();
