import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_bloc.dart';
import 'package:route_flow/features/map_routing/presentation/bloc/route_event.dart';

class DeepLinkLauncherScreen extends StatefulWidget {
  final String routeId;
  
  const DeepLinkLauncherScreen({
    super.key,
    required this.routeId,
  });

  @override
  State<DeepLinkLauncherScreen> createState() => _DeepLinkLauncherScreenState();
}

class _DeepLinkLauncherScreenState extends State<DeepLinkLauncherScreen> {
  @override
  void initState() {
    super.initState();
    // One-time trigger after the first frame to avoid side effects during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RouteBloc>().add(LoadSavedRouteById(widget.routeId));
        // Transition user into the main AppShell safely
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
