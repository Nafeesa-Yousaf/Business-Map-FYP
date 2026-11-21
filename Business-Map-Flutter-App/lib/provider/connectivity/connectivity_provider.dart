import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final InternetConnection _connection;
  StreamSubscription<InternetStatus>? _subscription;
  AppLifecycleListener? _lifecycleListener;

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  ConnectivityProvider({InternetConnection? connection})
      : _connection = connection ?? InternetConnection() {
    _startListening();
    _lifecycleListener = AppLifecycleListener(
      onResume: _startListening,
      onPause: () => _subscription?.cancel(),
    );
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = _connection.onStatusChange.listen((status) {
      final online = status == InternetStatus.connected;
      if (online == _isOnline) return;
      _isOnline = online;
      notifyListeners();
    });

    // Seed current status without waiting for the next stream event.
    _connection.hasInternetAccess.then((hasAccess) {
      if (hasAccess == _isOnline) return;
      _isOnline = hasAccess;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
