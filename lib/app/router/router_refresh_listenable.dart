import 'dart:async';
import 'package:flutter/material.dart';

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
