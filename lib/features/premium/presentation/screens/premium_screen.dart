import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_event.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_state.dart';
import 'package:route_flow/features/premium/presentation/widgets/premium_plan_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    context.read<PremiumBloc>().add(LoadPremiumOfferings());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabPremium),
      ),
      body: BlocConsumer<PremiumBloc, PremiumState>(
        listener: (context, state) {
          if (state.screenStatus == PremiumScreenStatus.failure && state.error != null) {
            final msg = state.error == 'purchase_failed' 
                ? l10n.premiumErrorPurchase 
                : l10n.premiumErrorOfferings;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        builder: (context, state) {
          if (state.screenStatus == PremiumScreenStatus.loading && state.offerings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status.isPremium) {
            return _ActivePremiumView();
          }

          final currentOffering = state.offerings?.current;
          if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
            return Center(child: Text(l10n.premiumErrorOfferings));
          }

          _selectedPackage ??= currentOffering.availablePackages.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, size: 64, color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.premiumTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.premiumSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                _BenefitItem(icon: Icons.check_circle, label: l10n.premiumBenefitUnlimited),
                _BenefitItem(icon: Icons.check_circle, label: l10n.premiumBenefitOffline),
                _BenefitItem(icon: Icons.check_circle, label: l10n.premiumBenefitSupport),
                const SizedBox(height: 48),
                ...currentOffering.availablePackages.map((package) => PremiumPlanCard(
                      package: package,
                      isSelected: _selectedPackage == package,
                      onTap: () => setState(() => _selectedPackage = package),
                    )),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: state.screenStatus == PremiumScreenStatus.purchasing
                      ? null
                      : () {
                          if (_selectedPackage != null) {
                            context.read<PremiumBloc>().add(PurchasePackage(_selectedPackage!));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: state.screenStatus == PremiumScreenStatus.purchasing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.premiumGetPro, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<PremiumBloc>().add(RestorePurchases()),
                  child: Text(l10n.premiumRestore),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BenefitItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ActivePremiumView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text(l10n.premiumActive, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(l10n.premiumBenefitUnlimited, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
