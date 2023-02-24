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
        assert(uriString.isNotEmpty, 'uriString must not be empty') {
    for (int i = 0; i < poolSize; i++) {
      _available.add(Db(uriString));
    }
  }

  /// Returns the number of available connections.
  get available => _available;

  /// Returns the number of connections in use.
  get inUse => _inUse;

  /// Throws an [Exception] if no connection is available.
  FutureOr<Db> acquire() async {
    if (_available.isEmpty) {
      throw Exception('No connection available');
    }
    final conn = _available.removeLast();
    _inUse.add(conn);
    return conn;
  }

  /// Releases a connection back to the pool.
  void release(Db conn) {
    if (_inUse.contains(conn)) {
      _inUse.remove(conn);
      _available.add(conn);
    }
  }

  /// Closes all connections in the pool.
  FutureOr<void> close() async {
    await Future.wait(_inUse.map((c) => c.close()));
    await Future.wait(_available.map((c) => c.close()));
    _inUse.clear();
    _available.clear();
  }
}
