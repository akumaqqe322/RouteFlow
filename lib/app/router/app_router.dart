import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:route_flow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:route_flow/features/splash/presentation/screens/splash_screen.dart';
import 'package:route_flow/features/auth/presentation/screens/auth_screen.dart';
import 'package:route_flow/features/home/presentation/screens/home_screen.dart';
import 'package:route_flow/features/my_routes/presentation/screens/my_routes_screen.dart';
import 'package:route_flow/features/premium/presentation/screens/premium_screen.dart';
import 'package:route_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';
import 'package:route_flow/app/router/router_refresh_listenable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:route_flow/features/map_routing/presentation/screens/deep_link_launcher_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshListenable([
      getIt<AuthBloc>().stream,
      getIt<OnboardingCubit>().stream,
    ]),
    redirect: (context, state) {
      final authState = getIt<AuthBloc>().state;
      final onboardingState = getIt<OnboardingCubit>().state;
      
      final String uri = state.uri.toString();
      final bool isRoutePath = uri.contains('/route/');
      final String? pendingRedirect = state.uri.queryParameters['redirect'];
      
      // Identify the target redirect to carry forward (encoded to survive query params)
      final String? targetRedirect = pendingRedirect ?? (isRoutePath ? uri : null);
      final String redirectQuery = targetRedirect != null 
          ? '?redirect=${Uri.encodeComponent(targetRedirect)}' 
          : '';

      final bool isAuthPath = uri.startsWith('/auth');
      final bool isSplashPath = uri.startsWith('/splash');
      final bool isOnboardingPath = uri.startsWith('/onboarding');

      // 1. Splash
      if (authState is AuthInitial || onboardingState is OnboardingInitial) {
        if (!isSplashPath) return '/splash$redirectQuery';
        return null;
      }

      // 2. Onboarding
      if (onboardingState is OnboardingIncomplete) {
        if (!isOnboardingPath) return '/onboarding$redirectQuery';
        return null;
      }

      // 3. Auth
      if (authState is Unauthenticated) {
        if (!isAuthPath) return '/auth$redirectQuery';
        return null;
      }

      // 4. Landing
      // If we are finished with flows but stuck on a splash/auth/onboarding path with a pending redirect
      if (targetRedirect != null && !uri.startsWith('/route/')) {
        return targetRedirect;
      }

      if (isAuthPath || isOnboardingPath || isSplashPath) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/route/:id',
        name: 'open_route',
        builder: (context, state) {
          final String id = state.pathParameters['id']!;
          return DeepLinkLauncherScreen(routeId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-routes',
                name: 'my-routes',
                builder: (context, state) => const MyRoutesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/premium',
                name: 'premium',
                builder: (context, state) => const PremiumScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            label: l10n.myRoutesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_outline),
            label: l10n.tabPremium,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
