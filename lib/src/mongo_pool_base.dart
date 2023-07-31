import 'dart:async';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/configuration/configuration_model.dart';
import 'package:mongo_pool/src/feature/connection_feature_model.dart';
import 'package:mongo_pool/src/feature/lifetime_checker.dart';

class MongoDbPool {
  /// Mongo pool configuration.
  late final MongoPoolConfiguration _config;

  /// The list of available connections.
  final List<ConnectionInfo> _available = [];

  /// The list of connections in use.
  final List<ConnectionInfo> _inUse = [];

  /// The lifetime checker.
  late LifetimeChecker _lifetimeChecker;

  /// Creates a new MongoDbPool instance.
  /// Creates [poolSize] number of connections and adds them to the available list.
  /// [uriString] is the connection string to use.
  /// Asserts that [poolSize] is greater than 0.
  /// Throws an [Exception] if [poolSize] is less than or equal to 0.
  /// Asserts that [uriString] is not empty.
  /// Throws an [Exception] if [uriString] is empty or null.
  /// Throws an [Exception] if [uriString] is not a valid connection string.
  MongoDbPool(this._config)
      : assert(_config.poolSize > 0, 'poolSize must be greater than 0'),
        assert(_config.uriString.isNotEmpty, 'uriString must not be empty') {
    _lifetimeChecker =
        LifetimeChecker(_available, _config.maxLifetimeMilliseconds, this);

    _startLifetimeChecker();
  }

  /// Opens all connections in the pool.
  Future<void> open() async {
    for (var i = 0; i < _config.poolSize; i++) {
      final conn = await Db.create(_config.uriString);
      try {
        await conn.open();
      } on Exception catch (e) {
        throw Exception('Error opening connection: $e');
      }
      _available.add(ConnectionInfo(conn));
    }
  }

  /// Returns the number of available connections.
  get available => _available;

  /// Returns the number of connections in use.
  get inUse => _inUse;

  /// Acquires a connection from the pool.
  Future<ConnectionInfo> acquire() async {
    if (_available.isEmpty) {
      _available.add(ConnectionInfo(await Db.create(_config.uriString)));
      await _available.last.connection.open();
    }
    final conn = _available.removeLast();
    _inUse.add(conn);
    return conn;
  }

  /// Releases a connection back to the pool.
  void release(ConnectionInfo connectionInfo) {
    if (_inUse.contains(connectionInfo)) {
      _inUse.remove(connectionInfo);
      connectionInfo.connection.close();
      openNewConnection();
    }
  }

  /// Closes all connections in the pool.
  Future<void> close() async {
    await Future.wait(_inUse.map((c) => c.connection.close()));
    await Future.wait(_available.map((c) => c.connection.close()));
    _inUse.clear();
    _available.clear();
  }

  /// Closes a connection.
  Future<void> closeConnection(ConnectionInfo connectionInformation) async {
    await connectionInformation.connection.close();
    _available.remove(connectionInformation);
    _inUse.remove(connectionInformation);
  }

  void openNewConnection() {
    Db.create(_config.uriString).then((conn) {
      conn.open().then((_) {
        _available.add(ConnectionInfo(conn));
      });
    });
  }

  void _startLifetimeChecker() => _lifetimeChecker.startChecking();
}
