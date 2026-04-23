import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_state.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState is Authenticated ? authState.user : null;
          
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Column(
                children: [
                  const Icon(Icons.person, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? '---',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<PremiumBloc, PremiumState>(
                    builder: (context, premiumState) {
                      final isPremium = premiumState.status.isPremium;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPremium ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPremium ? l10n.premiumActive : l10n.premiumFreePlan,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isPremium ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: Text(l10n.tabPremium),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/premium'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(l10n.authLogout),
                onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
              ),
            ],
          );
        },
      ),
    );
  }
}

