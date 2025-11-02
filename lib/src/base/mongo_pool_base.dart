import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/exception/exception.dart';
import 'package:mongo_pool/src/feature/connection_leak/leak_task_factory.dart';
import 'package:mongo_pool/src/feature/lifetime_checker/lifetime_checker.dart';
import 'package:mongo_pool/src/feature/pool_observer.dart';
import 'package:mongo_pool/src/model/connection_info_model.dart';

class MongoDbPoolBase extends Observer {
  /// Creates a new MongoDbPool instance.
  /// Creates poolSize number of connections and adds them to the available list.
  /// uriString is the connection string to use.
  /// Asserts that poolSize is greater than 0.
  /// Throws an [Exception] if poolSize is less than or equal to 0.
  /// Asserts that uriString is not empty.
  /// Throws an [Exception] if uriString is empty or null.
  /// Throws an [Exception] if uriString is not a valid connection string.
  MongoDbPoolBase(this._config)
      : assert(_config.poolSize > 0, 'poolSize must be greater than 0'),
        assert(_config.uriString.isNotEmpty, 'uriString must not be empty') {
    _lifetimeChecker = LifetimeChecker(
      allConnections,
      _config.maxLifetimeMilliseconds ?? 1800000,
      _config.poolSize,
    );

    /// if maxLifetimeMilliseconds is null in config, then set it to 0
    _proxyLeakTaskFactory =
        LeakTaskFactory(_config.leakDetectionThreshold ?? 0);

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

  late final LeakTaskFactory _proxyLeakTaskFactory;

  /// Opens all connections in the pool.
  Future<void> initialize() async {
    for (var i = 0; i < _config.poolSize; i++) {
      final conn = await Db.create(_config.uriString);
      try {
        await conn.open();
      } on Exception catch (e) {
        throw Exception('Error opening connection: $e');
      }
      final proxyLeakTask = _proxyLeakTaskFactory.createTask(conn);
      final connectionInfo = ConnectionInfo(
        conn,
        lastUseTime: DateTime.now(),
        leakTask: proxyLeakTask,
      );
      _available.add(
        connectionInfo,
      );
      _lifetimeChecker.updateConnections(allConnections);
    }
  }

  /// Opens all connections in the pool.
  @Deprecated('Use initialize() instead')
  Future<void> open() async {
    for (var i = 0; i < _config.poolSize; i++) {
      final conn = await Db.create(_config.uriString);
      try {
        await openConnection(conn);
      } on Exception catch (e) {
        throw Exception('Error opening connection: $e');
      }
      final proxyLeakTask = _proxyLeakTaskFactory.createTask(conn);
      final connectionInfo = ConnectionInfo(
        conn,
        lastUseTime: DateTime.now(),
        leakTask: proxyLeakTask,
      );
      _available.add(
        connectionInfo,
      );
      _lifetimeChecker.updateConnections(allConnections);
    }
  }

  List<ConnectionInfo> get allConnections => [..._available, ..._inUse];

  /// Returns the number of available connections.
  List<ConnectionInfo> get available => _available;

  /// Returns the number of connections in use.
  List<ConnectionInfo> get inUse => _inUse;

  List<ConnectionInfo> get _idleConnections =>
      _available.where((c) => c.isIdle).toList();

  /// Acquires a connection from the pool.
  Future<Db> acquire() async {
    if (_idleConnections.isEmpty) {
      await openNewConnection(_proxyLeakTaskFactory);
    }

    final lastIdleConnection = _idleConnections.last;

    // Perform health check if enabled
    if (!await _isConnectionHealthy(lastIdleConnection.connection)) {
      await _handleUnhealthyConnection(lastIdleConnection);
      // Recursively call acquire to get a healthy connection
      return acquire();
    }

    _available.remove(lastIdleConnection);
    _inUse.add(lastIdleConnection);
    _lifetimeChecker.updateConnections(allConnections);
    lastIdleConnection.leakTask.start();
    return lastIdleConnection.connection;
  }

  /// Releases a connection back to the pool.
  void release(Db connection) {
    final connectionInfo = _inUse.firstWhere(
      (c) => c.connection == connection,
      orElse: () => throw ConnectionNotFountMongoPoolException(),
    );
    _proxyLeakTaskFactory.cancelTask(connectionInfo.leakTask);
    if (connectionInfo.isIdle) {
      _inUse.remove(connectionInfo);
      _available.add(connectionInfo);
      connectionInfo.lastUseTime = DateTime.now();
    } else {
      closeConnection(connectionInfo);
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
    _proxyLeakTaskFactory.cancelTask(connectionInformation.leakTask);
    connectionInformation.lastUseTime = DateTime.now();
    _available.remove(connectionInformation);
    _inUse.remove(connectionInformation);
    _lifetimeChecker.updateConnections(allConnections);
  }

  Future<void> openNewConnection(LeakTaskFactory proxyLeakTaskFactory) =>
      Db.create(_config.uriString).then((conn) async {
        final proxyLeakTask = proxyLeakTaskFactory.createTask(conn);
        final connectionInfo = ConnectionInfo(
          conn,
          lastUseTime: DateTime.now(),
          leakTask: proxyLeakTask,
        );
        await openConnection(conn).then((_) {
          _available.add(
            connectionInfo,
          );
        });
      });

  void _startLifetimeChecker() {
    _lifetimeChecker
      ..subscribe(this)
      ..startChecking();
  }

  Future<void> openConnection(Db conn) async {
    return conn.open(
      writeConcern: _config.writeConcern,
      secure: _config.secure,
      tlsAllowInvalidCertificates: _config.tlsAllowInvalidCertificates,
      tlsCAFile: _config.tlsCAFile,
      tlsCertificateKeyFile: _config.tlsCertificateKeyFile,
      tlsCertificateKeyFilePassword: _config.tlsCertificateKeyFilePassword,
    );
  }

  /// Checks if a connection is healthy by performing a ping command.
  Future<bool> _isConnectionHealthy(Db connection) async {
    if (!_config.enableHealthCheck) {
      return true;
    }

    try {
      await connection
          .pingCommand()
          .timeout(Duration(milliseconds: _config.healthCheckTimeoutMs));
      return true;
    } on Exception catch (e) {
      log('Connection health check failed: $e');
      return false;
    } catch (e) {
      log('Connection health check failed: $e');
      if (e is MongoDartError) {
        return false;
      }
      rethrow;
    }
  }

  /// Handles an unhealthy connection by closing it and opening a new one.
  Future<void> _handleUnhealthyConnection(ConnectionInfo connectionInfo) async {
    log('Handling unhealthy connection, closing and creating new one');
    await closeConnection(connectionInfo);

    try {
      await openNewConnection(_proxyLeakTaskFactory);
      log('Successfully created new connection to replace unhealthy one');
    } on Exception catch (e) {
      log('Failed to create replacement connection: $e');
      // Don't throw here, let the pool continue with remaining connections
    }
  }

  @override
  void expiredConnectionNotifier(ConnectionInfo connectionInfo) {
    log('${connectionInfo.createTime} expired. Connection closing connection');
    closeConnection(connectionInfo);
    log('Opening new connection');
    if (allConnections.length < _config.poolSize) {
      log('Available connections less than minPoolSize. Opening new connection');
      openNewConnection(_proxyLeakTaskFactory);
    } else {
      log('Available connections greater than minPoolSize. Not opening new connection');
    }
  }
}
