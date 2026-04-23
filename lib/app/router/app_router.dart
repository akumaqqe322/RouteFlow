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
import 'package:route_flow/app/router/router_refresh_listenable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      
      final bool isAuthPath = state.uri.toString().startsWith('/auth');
      final bool isSplashPath = state.uri.toString().startsWith('/splash');
      final bool isOnboardingPath = state.uri.toString().startsWith('/onboarding');

      // 1. Initial State: Let splash handle initialization
      if (authState is AuthInitial || onboardingState is OnboardingInitial) {
        if (!isSplashPath) return '/splash';
        return null;
      }

      // 2. Onboarding Check (Highest Priority)
      if (onboardingState is OnboardingIncomplete) {
        if (!isOnboardingPath) return '/onboarding';
        return null;
      }

      // 3. Auth Check
      if (authState is Unauthenticated) {
        if (!isAuthPath) return '/auth';
        return null;
      }

      // 4. Authenticated & Onboarding Complete -> Handle edge case redirects
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
