import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:route_flow/app/app.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:route_flow/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  
  // Dependency Injection initialization (Config, Storage, Services)
  await configureDependencies();

  runApp(const RouteFlowApp());
}
