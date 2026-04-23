import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_state.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_state.dart';
import 'package:route_flow/features/map_routing/domain/entities/route_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:route_flow/features/saved_routes/presentation/widgets/save_route_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  static const LatLng _fallbackLocation = LatLng(51.5074, -0.1278);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(RequestLocationPermission());
    });
  }

  void _onMapTap(LatLng position) {
    final locationState = context.read<LocationBloc>().state;
    if (locationState.location != null) {
      context.read<RouteBloc>().add(
            BuildRouteRequested(
              start: LatLng(
                locationState.location!.latitude,
                locationState.location!.longitude,
              ),
              destination: position,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state.status == LocationStatus.success && state.location != null) {
                _mapController.move(
                  LatLng(state.location!.latitude, state.location!.longitude),
                  15.0,
                );
              }
            },
          ),
          BlocListener<RouteBloc, RouteState>(
            listener: (context, state) {
              if (state.status == RouteStatus.success && state.route != null) {
                // Determine the center to move to
                final center = state.destination ?? 
                  state.route!.points[state.route!.points.length ~/ 2];
                
                _mapController.move(center, 14.0);
              }

              if (state.status == RouteStatus.failure && state.error == 'route_not_found') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorRouteNotFound)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, locationState) {
          if (locationState.status == LocationStatus.loading && locationState.location == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (locationState.status == LocationStatus.servicesDisabled) {
            return const _ServicesDisabledView();
          }

          if (locationState.status == LocationStatus.permissionDenied || 
              locationState.status == LocationStatus.permissionPermanentlyDenied) {
            return _PermissionDeniedView(
              isPermanent: locationState.status == LocationStatus.permissionPermanentlyDenied,
            );
          }

          return BlocBuilder<RouteBloc, RouteState>(
            builder: (context, routeState) {
              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: locationState.location != null
                          ? LatLng(locationState.location!.latitude, locationState.location!.longitude)
                          : _fallbackLocation,
                      initialZoom: locationState.location != null ? 15.0 : 10.0,
                      onTap: (_, pos) => _onMapTap(pos),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.route_flow',
                      ),
                      if (routeState.route != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routeState.route!.points,
                              strokeWidth: 5,
                              color: Colors.green.withOpacity(0.8),
                            ),
                          ],
                        ),
                      if (locationState.location != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(locationState.location!.latitude, locationState.location!.longitude),
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                            ),
                          ],
                        ),
                      if (routeState.destination != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: routeState.destination!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  // Top Status Bar / Hint / Error
                  if (routeState.status == RouteStatus.initial || routeState.status == RouteStatus.failure)
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: _RouteStatusCard(
                        status: routeState.status,
                        errorMessage: routeState.error,
                      ),
                    ),

                  // Route Details Panel
                  if (routeState.route != null && locationState.location != null)
                    _RouteDetailsPanel(
                      route: routeState.route!,
                      start: LatLng(
                        locationState.location!.latitude,
                        locationState.location!.longitude,
                      ),
                      destination: routeState.destination!,
                    ),

                  // My Location Button
                  Positioned(
                    bottom: routeState.route != null ? 220 : 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'my_location_btn',
                      onPressed: () => context.read<LocationBloc>().add(GetCurrentLocation()),
                      child: const Icon(Icons.my_location),
                    ),
                  ),

                  if (routeState.status == RouteStatus.loading)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _RouteStatusCard extends StatelessWidget {
  final RouteStatus status;
  final String? errorMessage;

  const _RouteStatusCard({
    required this.status,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (status == RouteStatus.initial) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(l10n.routeSelectDestinationHint, textAlign: TextAlign.center),
        ),
      );
    }

    if (status == RouteStatus.failure) {
      String message;
      switch (errorMessage) {
        case 'route_not_found':
          message = l10n.routeErrorNoRoute;
          break;
        case 'route_network_error':
          message = l10n.routeErrorNetwork;
          break;
        default:
          message = l10n.routeErrorUnexpected;
      }

      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => context.read<RouteBloc>().add(ClearRouteRequested()),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _RouteDetailsPanel extends StatelessWidget {
  final RouteInfo route;
  final LatLng start;
  final LatLng destination;

  const _RouteDetailsPanel({
    required this.route,
    required this.start,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final distanceKm = (route.distance / 1000).toStringAsFixed(1);
    final durationMin = (route.duration / 60).round();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PointInfo(
                      label: l10n.routeStartLabel,
                      coords: start,
                      icon: Icons.my_location,
                      iconColor: Colors.blue,
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                  Expanded(
                    child: _PointInfo(
                      label: l10n.routeDestinationLabel,
                      coords: destination,
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _DetailItem(
                    label: l10n.routeDistanceLabel,
                    value: '$distanceKm km',
                    icon: Icons.straighten,
                  ),
                  _DetailItem(
                    label: l10n.routeDurationLabel,
                    value: '$durationMin min',
                    icon: Icons.timer_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<RouteBloc>().add(ClearRouteRequested()),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: Text(l10n.routeClearBtn),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => SaveRouteDialog(
                            routeInfo: route,
                            start: start,
                            destination: destination,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                      ),
                      child: Text(l10n.routeSaveBtn),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointInfo extends StatelessWidget {
  final String label;
  final LatLng coords;
  final IconData icon;
  final Color iconColor;

  const _PointInfo({
    required this.label,
    required this.coords,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "${coords.latitude.toStringAsFixed(5)}, ${coords.longitude.toStringAsFixed(5)}",
          style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ServicesDisabledView extends StatelessWidget {
  const _ServicesDisabledView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ErrorOverlayView(
      icon: Icons.location_disabled,
      title: l10n.mapServicesDisabledTitle,
      description: l10n.mapServicesDisabledDesc,
      buttonLabel: l10n.mapServicesDisabledBtn,
      onPressed: () => context.read<LocationBloc>().add(const OpenLocationSettings(isAppSettings: false)),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final bool isPermanent;

  const _PermissionDeniedView({required this.isPermanent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _ErrorOverlayView(
      icon: Icons.location_off,
      title: l10n.mapPermissionTitle,
      description: isPermanent ? l10n.mapPermissionPermanentlyDenied : l10n.mapPermissionDesc,
      buttonLabel: isPermanent ? l10n.mapServicesDisabledBtn : l10n.mapPermissionBtn,
      onPressed: () {
        if (isPermanent) {
          context.read<LocationBloc>().add(const OpenLocationSettings(isAppSettings: true));
        } else {
          context.read<LocationBloc>().add(RequestLocationPermission());
        }
      },
    );
  }
}

class _ErrorOverlayView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _ErrorOverlayView({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(description, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

