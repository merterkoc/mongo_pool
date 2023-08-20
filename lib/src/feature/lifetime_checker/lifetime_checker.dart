import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/src/feature/pool_observer.dart';
import 'package:mongo_pool/src/model/connection_info_model.dart';

class LifetimeChecker extends PoolObservable {
  LifetimeChecker(this._allConnections, this._maxLifetimeMilliseconds)
      : super();
  final List<ConnectionInfo> _allConnections;
  final int _maxLifetimeMilliseconds;

  void startChecking() {
    log('Max lifetime: $_maxLifetimeMilliseconds milliseconds\nAvailable connections: ${_allConnections.length}');
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final now = DateTime.now();
      final expiredConnections = <ConnectionInfo>[];

      for (final connInfo in _allConnections) {
        final elapsedMilliseconds =
            now.difference(connInfo.createTime).inMilliseconds;
        if (elapsedMilliseconds >= _maxLifetimeMilliseconds &&
                !connInfo.inUse ||
            connInfo.leakTask.state.isLeaked) {
          expiredConnections.add(connInfo);
        }
      }

      for (final connInfo in expiredConnections) {
        await _closeConnection(connInfo);
      }
    });
  }

  Future<void> _closeConnection(ConnectionInfo connectionInfo) async {
    notifyExpire(connectionInfo);
  }
}
