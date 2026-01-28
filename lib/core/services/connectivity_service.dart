import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityService {
  // Define the getter clearly
  Stream<NetworkStatus> get connectivityStream =>
      Connectivity().onConnectivityChanged.map((List<ConnectivityResult> results) {
        // If the list is empty or only contains 'none', the user is offline
        if (results.isEmpty || results.contains(ConnectivityResult.none)) {
          return NetworkStatus.offline;
        }
        return NetworkStatus.online;
      });
}