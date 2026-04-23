import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:route_flow/app/router/app_router.dart';
import 'package:route_flow/app/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';

import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_event.dart';

class RouteFlowApp extends StatelessWidget {
  const RouteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<OnboardingCubit>()),
        BlocProvider(create: (context) => getIt<LocationBloc>()),
        BlocProvider(create: (context) => getIt<RouteBloc>()),
        BlocProvider(create: (context) => getIt<SavedRoutesBloc>()..add(const LoadSavedRoutes())),
        BlocProvider(create: (context) => getIt<PremiumBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<PremiumBloc>().add(InitializePremium(state.user.id));
          }
        },
        child: MaterialApp.router(
        title: 'RouteFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
    );
  }
}
