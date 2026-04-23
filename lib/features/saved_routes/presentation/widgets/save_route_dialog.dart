import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';

import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:route_flow/features/premium/domain/logic/premium_policy.dart';
import 'package:route_flow/features/premium/presentation/bloc/premium_bloc.dart';

class SaveRouteDialog extends StatefulWidget {
  final RouteInfo routeInfo;
  final LatLng start;
  final LatLng destination;

  const SaveRouteDialog({
    super.key,
    required this.routeInfo,
    required this.start,
    required this.destination,
  });

  @override
  State<SaveRouteDialog> createState() => _SaveRouteDialogState();
}

class _SaveRouteDialogState extends State<SaveRouteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = context.watch<PremiumBloc>().state.status.isPremium;
    final routesCount = context.watch<SavedRoutesBloc>().state.routes.length;
    
    final canSave = PremiumPolicy.canSaveMoreRoutes(
      isPremium: isPremium,
      currentRoutesCount: routesCount,
    );

    if (!canSave) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.premiumLimitReached)),
          ],
        ),
        content: Text(l10n.premiumLimitDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/premium');
            },
            child: Text(l10n.premiumUpgradeNow),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.routeSaveDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.routeSaveDialogHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              context.read<SavedRoutesBloc>().add(
                    SaveBuiltRoute(
                      title: _controller.text.trim(),
                      routeInfo: widget.routeInfo,
                      start: widget.start,
                      destination: widget.destination,
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.routeSaveSuccess)),
              );
            }
          },
          child: Text(l10n.routeSaveDialogAction),
        ),
      ],
    );
  }
}
