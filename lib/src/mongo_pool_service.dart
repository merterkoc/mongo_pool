import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_pool/src/mongo_pool_base.dart';

/// This class is a singleton that provides a pool of connections to the database
class MongoDbPoolService {
  /// This [poolSize] is the number of connections that will be created
  /// Pool Size will increase as requests increase
  final int poolSize;

  /// Example: 'mongodb://localhost:27017/my_database'
  /// Example: 'mongodb://user:password@localhost:27017/my_database'
  /// This [mongoDbUri] is the connection string to the database
  final String mongoDbUri;

  /// This is the singleton instance
  static MongoDbPoolService? _instance;

  /// This is the pool of connections
  MongoDbPool _pool;

  /// This is the constructor
  factory MongoDbPoolService({required poolSize, required String mongoDbUri}) {
    _instance ??= MongoDbPoolService._internal(
        poolSize: poolSize, mongoDbUri: mongoDbUri);
    return _instance as MongoDbPoolService;
  }

  /// This is the constructor
  /// If Instance does not exist, it creates one with default values.
  /// Use [MongoDbPoolService] to create instance
  /// Example: MongoDbPoolService(poolSize: 5,mongoDbUri: 'mongodb://localhost:227/my_database');
  static MongoDbPoolService getInstance(
      {int poolSize = 3, String mongoDbUri = "mongodb://localhost:27017"}) {
    _instance ??= MongoDbPoolService._internal(
        poolSize: poolSize, mongoDbUri: mongoDbUri);
    return _instance as MongoDbPoolService;
  }

  MongoDbPool get pool => _pool;

  /// This is the private constructor
  MongoDbPoolService._internal(
      {required this.poolSize, required this.mongoDbUri})
      : _pool = MongoDbPool(poolSize, mongoDbUri);

  /// This method opens the pool of connections
  Future<MongoDbPool> open() async {
    /// This method opens the pool of connections
    /// If you take error, check the connection string
    try {
      await _pool.open();
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
  Future<void> release(Db conn) async {
    /// This method releases a connection to the pool
    _pool.release(conn);
  }

  /// This method closes the pool of connections
  Future<void> close() async => _pool.close();
}
