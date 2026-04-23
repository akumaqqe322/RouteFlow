import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_bloc.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_event.dart';
import 'package:route_flow/features/saved_routes/presentation/bloc/saved_routes_state.dart';
import 'package:route_flow/features/saved_routes/presentation/widgets/route_card.dart';

class MyRoutesScreen extends StatelessWidget {
  const MyRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRoutesTitle),
      ),
      body: BlocBuilder<SavedRoutesBloc, SavedRoutesState>(
        builder: (context, state) {
          if (state.status == SavedRoutesStatus.loading && state.routes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SavedRoutesStatus.failure && state.routes.isEmpty) {
            return Center(child: Text(state.error ?? 'Error'));
          }

          if (state.routes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.myRoutesEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<SavedRoutesBloc>().add(const LoadSavedRoutes(forceRefresh: true));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.routes.length,
              itemBuilder: (context, index) {
                final route = state.routes[index];
                return RouteCard(
                  route: route,
                  onTap: () {
                    context.read<RouteBloc>().add(RestoreSavedRoute(route));
                    context.go('/home');
                  },
                  onFavoriteToggle: () {
                    context.read<SavedRoutesBloc>().add(ToggleFavoriteRoute(route));
                  },
                  onRename: (newName) {
                    context.read<SavedRoutesBloc>().add(RenameRoute(route, newName));
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, route.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myRoutesDelete),
        content: Text(l10n.myRoutesDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SavedRoutesBloc>().add(DeleteRoute(id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.myRoutesDelete),
          ),
        ],
      ),
    );
  }
}
