import 'package:connectivity_plus/connectivity_plus.dart';

import '../errors/exceptions.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

extension NetworkInfoGuard on NetworkInfo {
  Future<void> ensureConnected() async {
    if (!await isConnected) throw const NoConnectionException();
  }
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
  }
}
