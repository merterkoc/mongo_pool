import 'dart:async';

import 'package:mongo_pool/mongo_pool.dart';

class MongoDbPool {
  /// The number of connections in the pool.
  final int poolSize;

  /// The connection string to use.
  final String uriString;

  /// The list of available connections.
  final List<Db> _available = [];

  /// The list of connections in use.
  final List<Db> _inUse = [];

  /// Creates a new MongoDbPool instance.
  /// Creates [poolSize] number of connections and adds them to the available list.
  /// [uriString] is the connection string to use.
  /// Asserts that [poolSize] is greater than 0.
  /// Throws an [Exception] if [poolSize] is less than or equal to 0.
  /// Asserts that [uriString] is not empty.
  /// Throws an [Exception] if [uriString] is empty or null.
  /// Throws an [Exception] if [uriString] is not a valid connection string.
  MongoDbPool(this.poolSize, this.uriString)
      : assert(poolSize > 0, 'poolSize must be greater than 0'),
        assert(uriString.isNotEmpty, 'uriString must not be empty');

  /// Opens all connections in the pool.
  Future<void> open() async {
    for (var i = 0; i < poolSize; i++) {
      final conn = await Db.create(uriString);
      try {
        await conn.open();
      } on Exception catch (e) {
        throw Exception('Error opening connection: $e');
      }
      _available.add(conn);
    }
  }

  /// Returns the number of available connections.
  get available => _available;

  /// Returns the number of connections in use.
  get inUse => _inUse;

  /// Acquires a connection from the pool.
  Future<Db> acquire() async {
    if (_available.isEmpty) {
      _available.add(await Db.create(uriString));
      await _available.last.open();
    }
    final conn = _available.removeLast();
    _inUse.add(conn);
    return conn;
  }

  /// Releases a connection back to the pool.
  void release(Db conn) {
    if (_inUse.contains(conn)) {
      _inUse.remove(conn);
      conn.close();
      openNewConnection();
    }
  }

  /// Closes all connections in the pool.
  Future<void> close() async {
    await Future.wait(_inUse.map((c) => c.close()));
    await Future.wait(_available.map((c) => c.close()));
    _inUse.clear();
    _available.clear();
  }

  void openNewConnection() {
    Db.create(uriString).then((conn) {
      conn.open().then((_) {
        _available.add(conn);
      });
    });
  }
}
