import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/src/feature/connection_feature_model.dart';
import 'package:mongo_pool/src/feature/observer.dart';

class LifetimeChecker extends Observable {
  LifetimeChecker(this._connections, this._maxLifetimeMilliseconds) : super();
  final List<ConnectionInfo> _connections;
  final int _maxLifetimeMilliseconds;

  void startChecking() {
    log('Max lifetime: $_maxLifetimeMilliseconds milliseconds\nAvailable connections: ${_connections.length}');
    Timer.periodic(const Duration(seconds: 1), (timer) async {

      final now = DateTime.now();
      final expiredConnections = <ConnectionInfo>[];

      for (final connInfo in _connections) {
        final elapsedMilliseconds =
            now.difference(connInfo.createTime).inMilliseconds;
        if (elapsedMilliseconds >= _maxLifetimeMilliseconds) {
          expiredConnections.add(connInfo);
        }
      }

      for (final connInfo in expiredConnections) {
        await _closeConnection(connInfo);
        // You might want to add a new connection here, but it's not necessary as new connections are opened when needed.
      }
    });
  }

  Future<void> _closeConnection(ConnectionInfo connectionInfo) async {
    notifyExpire(connectionInfo);
  }
}
