import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:route_flow/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final steps = [
      _OnboardingStep(
        title: l10n.onboardingStep1Title,
        description: l10n.onboardingStep1Desc,
        icon: Icons.explore_outlined,
      ),
      _OnboardingStep(
        title: l10n.onboardingStep2Title,
        description: l10n.onboardingStep2Desc,
        icon: Icons.show_chart,
      ),
      _OnboardingStep(
        title: l10n.onboardingStep3Title,
        description: l10n.onboardingStep3Desc,
        icon: Icons.people_outline,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (int page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step.icon, size: 120, color: Colors.green),
                        const SizedBox(height: 48),
                        Text(
                          step.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        context.read<OnboardingCubit>().completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      _currentPage < steps.length - 1 ? l10n.onboardingNext : l10n.onboardingFinish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

