import 'package:meta/meta.dart';
import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/base/mongo_pool_base.dart';
import 'package:mongo_pool/src/exception/exception.dart';

/// This class is a singleton that provides a pool of connections to the database
class MongoDbPoolService {
  /// This is the constructor
  factory MongoDbPoolService(MongoPoolConfiguration config) {
    _instance ??= MongoDbPoolService._internal(config);
    return _instance!;
  }

  /// This is the private constructor
  MongoDbPoolService._internal(this.config) : _pool = MongoDbPoolBase(config);

  /// Example: 'mongodb://localhost:27017/my_database'
  /// Example: 'mongodb://user:password@localhost:27017/my_database'
  /// This mongoDbUri is the connection string to the database
  /// This poolSize is the number of connections that will be created
  /// Pool Size will increase as requests increase
  final MongoPoolConfiguration config;

  /// This is the singleton instance
  static MongoDbPoolService? _instance;

  /// This is the pool of connections
  MongoDbPoolBase _pool;

  /// This is the constructor
  /// If Instance does not exist, it creates one with default values.
  /// Use [MongoDbPoolService] to create instance
  /// Example: MongoDbPoolService(poolSize: 5,mongoDbUri: 'mongodb://localhost:227/my_database');
  static MongoDbPoolService getInstance() {
    return _instance == null
        ? throw NotInitializedMongoPoolException()
        : _instance!;
  }

  @visibleForTesting
  MongoDbPoolBase get pool => _pool;

  /// This method returns the number of connections in the pool
  int get availableConnectionLength => _pool.available.length;

  /// This method returns the number of connections in the pool
  int get inUseConnectionLength => _pool.inUse.length;

  /// This method opens the pool of connections for the first time
  Future<MongoDbPoolBase> initialize() async {
    /// This method opens the pool of connections
    /// If you take error, check the connection string
    if (_pool.allConnections.isNotEmpty) {
      throw PoolAlreadyOpenMongoPoolException();
    }
    try {
      await _pool.initialize();
    } on Exception catch (e) {
      throw Exception('Error opening pool: $e');
    }
    return _pool;
  }


  /// This method opens the pool of connections
  @Deprecated('Use initialize() instead')
  Future<MongoDbPoolBase> open() async {
    /// This method opens the pool of connections
    /// If you take error, check the connection string
    if (_pool.allConnections.isNotEmpty) {
      throw PoolAlreadyOpenMongoPoolException();
    }
    try {
      await _pool.initialize();
    } on Exception catch (e) {
      throw Exception('Error opening pool: $e');
    }
    return _pool;
  }

  Future<Db> acquire() async {
    /// This method gets a connection from the pool
    return _pool.acquire();
  }

  /// This method releases a connection to the pool
  void release(Db connection) {
    /// This method releases a connection to the pool
    _pool.release(connection);
  }

  /// This method closes the pool of connections
  Future<void> close() async => _pool.closeAllConnection();
}
