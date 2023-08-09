import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/exception/exception.dart';
import 'package:mongo_pool/src/feature/connection_info_model.dart';
import 'package:mongo_pool/src/feature/lifetime_checker.dart';
import 'package:mongo_pool/src/feature/observer.dart';

class MongoDbPool extends Observer {
  /// Creates a new MongoDbPool instance.
  /// Creates poolSize number of connections and adds them to the available list.
  /// uriString is the connection string to use.
  /// Asserts that poolSize is greater than 0.
  /// Throws an [Exception] if poolSize is less than or equal to 0.
  /// Asserts that uriString is not empty.
  /// Throws an [Exception] if uriString is empty or null.
  /// Throws an [Exception] if uriString is not a valid connection string.
  MongoDbPool(this._config)
      : assert(_config.poolSize > 0, 'poolSize must be greater than 0'),
        assert(_config.uriString.isNotEmpty, 'uriString must not be empty') {
    _lifetimeChecker =
        LifetimeChecker(_available, _config.maxLifetimeMilliseconds);

    _startLifetimeChecker();
  }

  /// Mongo pool configuration.
  late final MongoPoolConfiguration _config;

  /// The list of available connections.
  final List<ConnectionInfo> _available = [];

  /// The list of connections in use.
  final List<ConnectionInfo> _inUse = [];

  /// The lifetime checker.
  late LifetimeChecker _lifetimeChecker;

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
  List<ConnectionInfo> get available => _available;

  /// Returns the number of connections in use.
  List<ConnectionInfo> get inUse => _inUse;

  /// Acquires a connection from the pool.
  Future<Db> acquire() async {
    if (_available.isEmpty) {
      await openNewConnection();
    }
    final conn = _available.removeLast();
    _inUse.add(conn);
    return conn.connection;
  }

  /// Releases a connection back to the pool.
  void release(Db connection) {
    final connectionInfo = _inUse.firstWhere(
      (c) => c.connection == connection,
      orElse: () => throw ConnectionNotFountMongoPoolException(),
    );
    if (_inUse.contains(connectionInfo)) {
      _inUse.remove(connectionInfo);
    }
  }

  /// Closes all connections in the pool.
  Future<void> closeAllConnection() async {
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

  Future<void> openNewConnection() =>
      Db.create(_config.uriString).then((conn) async {
        await conn.open().then((_) {
          _available.add(ConnectionInfo(conn));
        });
      });

  void _startLifetimeChecker() {
    _lifetimeChecker
      ..subscribe(this)
      ..startChecking();
  }

  @override
  void expiredConnectionNotifier(ConnectionInfo connectionInfo) {
    log('${connectionInfo.createTime} expired. Connection closing connection');
    closeConnection(connectionInfo);
    log('Opening new connection');
    openNewConnection();
  }
}
