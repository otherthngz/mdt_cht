import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class SyncCoordinator {
  SyncCoordinator({
    required SyncService syncService,
    Connectivity? connectivity,
    Duration? pollInterval,
  })  : _syncService = syncService,
        _connectivity = connectivity ?? Connectivity(),
        _pollInterval = pollInterval ?? const Duration(seconds: 30);

  final SyncService _syncService;
  final Connectivity _connectivity;
  final Duration _pollInterval;

  Timer? _timer;
  StreamSubscription<dynamic>? _connectivitySub;

  void start() {
    _timer ??= Timer.periodic(_pollInterval, (_) => _trySync());
    _connectivitySub ??= _connectivity.onConnectivityChanged.listen((_) {
      _trySync();
    });
    _trySync();
  }

  Future<void> manualSyncNow() async {
    await _syncService.syncNow();
  }

  Future<void> _trySync() async {
    final connected = await _isConnected();
    if (!connected) {
      return;
    }
    await _syncService.syncNow();
  }

  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.any((item) => item != ConnectivityResult.none);
    }
    return true;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}
