import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_event.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/location_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  // Falling back to a product-appropriate high-level view (London)
  static const LatLng _fallbackLocation = LatLng(51.5074, -0.1278);

  @override
  void initState() {
    super.initState();
    // Move permission request to the map feature lifecycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(RequestLocationPermission());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.success && state.location != null) {
            _mapController.move(
              LatLng(state.location!.latitude, state.location!.longitude),
              15.0,
            );
          }
        },
        builder: (context, state) {
          if (state.status == LocationStatus.loading && state.location == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == LocationStatus.servicesDisabled) {
            return const _ServicesDisabledView();
          }

          if (state.status == LocationStatus.permissionDenied || 
              state.status == LocationStatus.permissionPermanentlyDenied) {
            return _PermissionDeniedView(
              isPermanent: state.status == LocationStatus.permissionPermanentlyDenied,
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.location != null
                      ? LatLng(state.location!.latitude, state.location!.longitude)
                      : _fallbackLocation,
                  initialZoom: state.location != null ? 15.0 : 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.route_flow',
                  ),
                  if (state.location != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(state.location!.latitude, state.location!.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () => context.read<LocationBloc>().add(GetCurrentLocation()),
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
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

