import 'package:mongo_pool/src/mongo_pool_service.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final poolService = MongoDbPoolService(
    poolSize: 5,
    mongoDbUri: 'mongodb://localhost:27017/my_database',
  );

  /// Open the pool
  await openDbPool(poolService);

  /// Get a connection from pool
  final conn = await poolService.acquire();

  // Database operations
  final collection = conn.collection('my_collection');
  final result = await collection.find().toList();
  // Connection release for other operations
  poolService.release(conn);

  // Pool close
  await poolService.close();
}

Future<void> openDbPool(MongoDbPoolService service) async {
  try {
    await service.open();
  } on Exception catch (e) {
    /// handle the exception here
    print(e.toString());
  }
}

class OtherClass {
  OtherClass();

  Future<void> openDbPool() async {
    /// Get the instance of the pool
    final poolService = MongoDbPoolService.getInstance();
    final conn = await poolService.acquire();
    // Database operations
    final collection = conn.collection('my_collection');
    final result = await collection.find().toList();
    // Connection release for other operations
    poolService.release(conn);
    // Pool close
    await poolService.close();
  }
}
