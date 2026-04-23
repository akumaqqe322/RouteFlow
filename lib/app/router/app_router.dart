import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:route_flow/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:route_flow/features/splash/presentation/screens/splash_screen.dart';
import 'package:route_flow/features/auth/presentation/screens/auth_screen.dart';
import 'package:route_flow/features/home/presentation/screens/home_screen.dart';
import 'package:route_flow/features/my_routes/presentation/screens/my_routes_screen.dart';
import 'package:route_flow/features/premium/presentation/screens/premium_screen.dart';
import 'package:route_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:route_flow/app/di/di.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = getIt<AuthBloc>().state;
      
      final bool isAuthPath = state.uri.toString().startsWith('/auth');
      final bool isSplashPath = state.uri.toString().startsWith('/splash');

      // 1. Splash should always be allowed to finish or redirect
      if (isSplashPath) return null;

      // 2. Not logged in -> Auth
      if (authState is Unauthenticated && !isAuthPath) {
        return '/auth';
      }

      // 3. Logged in and trying to go to Auth -> Home
      if (authState is Authenticated && isAuthPath) {
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Premium'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
