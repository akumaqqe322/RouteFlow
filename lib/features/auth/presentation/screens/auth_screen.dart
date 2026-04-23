import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:route_flow/app/di/di.dart';
import 'package:route_flow/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:route_flow/features/auth/presentation/cubit/sign_in_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => getIt<SignInCubit>(),
      child: BlocConsumer<SignInCubit, SignInState>(
        listener: (context, state) {
          if (state.status == SignInStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? l10n.authGenericError)),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SignInCubit>();

          return Scaffold(
            appBar: AppBar(
              title: Text(state.isLoginMode ? l10n.loginTitle : l10n.registerTitle),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.route, size: 80, color: Colors.green),
                  const SizedBox(height: 48),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      errorText: state.email.isNotEmpty && !state.email.contains('@') 
                          ? l10n.invalidEmailError 
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: cubit.emailChanged,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      errorText: state.password.isNotEmpty && state.password.length < 6 
                          ? l10n.invalidPasswordError 
                          : null,
                    ),
                    obscureText: true,
                    onChanged: cubit.passwordChanged,
                  ),
                  const SizedBox(height: 32),
                  if (state.status == SignInStatus.loading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: state.isValid ? cubit.submit : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(state.isLoginMode ? l10n.signInButton : l10n.signUpButton),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: cubit.toggleMode,
                    child: Text(state.isLoginMode ? l10n.noAccountText : l10n.haveAccountText),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

