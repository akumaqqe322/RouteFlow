import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:route_flow/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
              child: Text(l10n.logoutButton, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

