import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/src/feature/connection_feature_model.dart';
import 'package:mongo_pool/src/feature/observer.dart';

class LifetimeChecker extends Observable {
  final List<ConnectionInfo> _connections;
  final int _maxLifetimeMilliseconds;

  LifetimeChecker(this._connections, this._maxLifetimeMilliseconds) : super();

  void startChecking() {
    log('Max lifetime: $_maxLifetimeMilliseconds milliseconds\nAvailable connections: ${_connections.length}');
    Timer.periodic(Duration(seconds: 1),
        //TODO change to seconds
        (timer) async {
      print(_connections.map((e) => e.createTime).toList());

      final now = DateTime.now();
      List<ConnectionInfo> expiredConnections = [];

      for (var connInfo in _connections) {
        final int elapsedMilliseconds =
            now.difference(connInfo.createTime).inMilliseconds;
        if (elapsedMilliseconds >= _maxLifetimeMilliseconds) {
          expiredConnections.add(connInfo);
        }
      }

      for (var connInfo in expiredConnections) {
        await _closeConnection(connInfo);
        // You might want to add a new connection here, but it's not necessary as new connections are opened when needed.
      }
    });
  }

  Future<void> _closeConnection(ConnectionInfo connectionInfo) async {
    notifyExpire(connectionInfo);
  }
}
