import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityService {
  // Use a StreamController to broadcast status changes
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();

  Stream<NetworkStatus> get statusStream => _statusController.stream;

  ConnectivityService() {
    // Listen to the connectivity_plus stream
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _statusController.add(_getStatusFromResult(results));
    });
  }

  NetworkStatus _getStatusFromResult(List<ConnectivityResult> results) {
    // If the list contains anything other than 'none', we are online
    return results.contains(ConnectivityResult.none)
        ? NetworkStatus.offline
        : NetworkStatus.online;
  }
}