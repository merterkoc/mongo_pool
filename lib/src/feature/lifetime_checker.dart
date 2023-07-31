import 'dart:async';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_feature_model.dart';

class LifetimeChecker {
  final List<ConnectionInfo> _connections;
  final int _maxLifetimeMilliseconds;

  LifetimeChecker(this._connections, this._maxLifetimeMilliseconds);

  void startChecking() {
    print('Starting lifetime checker...');
    print('Max lifetime: $_maxLifetimeMilliseconds milliseconds');
    print('Available connections: ${_connections.length}');
    Timer.periodic(Duration(milliseconds: 5000),
        (timer) async {
      print('Checking lifetime...');
      print('Available connections: ${_connections.length}');
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
        await _closeConnection(connInfo.connection);
        // You might want to add a new connection here, but it's not necessary as new connections are opened when needed.
      }
    });
  }

  Future<void> _closeConnection(Db conn) async {
    try {
      await conn.close();
    } on Exception catch (e) {
      throw Exception('Error closing connection: $e');
    }
  }
}
