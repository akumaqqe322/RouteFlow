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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      body: BlocBuilder<LocationBloc, LocationState>(
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
                  
                  // Top Status Bar / Hint
                  if (routeState.status == RouteStatus.initial)
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            l10n.routeSelectDestinationHint,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                  // Route Details Panel
                  if (routeState.route != null)
                    _RouteDetailsPanel(route: routeState.route!),

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

class _RouteDetailsPanel extends StatelessWidget {
  final dynamic route;

  const _RouteDetailsPanel({required this.route});

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
              ElevatedButton(
                onPressed: () => context.read<RouteBloc>().add(ClearRouteRequested()),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
                child: Text(l10n.routeClearBtn),
              ),
            ],
          ),
        ),
      ),
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

