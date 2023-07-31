import 'dart:async';

import 'package:mongo_pool/src/feature/connection_feature_model.dart';
import 'package:mongo_pool/src/mongo_pool_base.dart';

class LifetimeChecker {
  final List<ConnectionInfo> _connections;
  final int _maxLifetimeMilliseconds;
  final MongoDbPool _mongoDbPool;

  LifetimeChecker(this._connections, this._maxLifetimeMilliseconds, this._mongoDbPool);

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
        await _closeConnection(connInfo);
        // You might want to add a new connection here, but it's not necessary as new connections are opened when needed.
      }
    });
  }

  Future<void> _closeConnection(ConnectionInfo connectionInfo) async {
    try {

      _mongoDbPool.closeConnection(connectionInfo);
    } on Exception catch (e) {
      throw Exception('Error closing connection: $e');
    }
  }
}
