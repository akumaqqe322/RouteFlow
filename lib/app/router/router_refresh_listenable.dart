import 'dart:async';
import 'package:flutter/material.dart';

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(List<Stream<dynamic>> streams) {
    notifyListeners();
    for (final stream in streams) {
      final subscription = stream.asBroadcastStream().listen(
            (_) => notifyListeners(),
          );
      _subscriptions.add(subscription);
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
