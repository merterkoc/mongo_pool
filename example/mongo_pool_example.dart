import 'package:mongo_pool/src/configuration/configuration_model.dart';
import 'package:mongo_pool/src/mongo_pool_service.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final poolService = MongoDbPoolService(MongoPoolConfiguration(
      maxLifetimeMilliseconds: 1000,
      uriString: 'mongodb://localhost:27017/my_database',
      poolSize: 4));

  /// Open the pool
  await openDbPool(poolService);

  /// Get a connection from pool
  final connectionInfo = await poolService.acquire();

  // Database operations
  final collection = connectionInfo.connection.collection('my_collection');
  final result = await collection.find().toList();
  // Connection release for other operations
  poolService.release(connectionInfo);

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
    final connectionInfo = await poolService.acquire();
    // Database operations
    final collection = connectionInfo.connection.collection('my_collection');
    final result = await collection.find().toList();
    // Connection release for other operations
    poolService.release(connectionInfo);
    // Pool close
    await poolService.close();
  }
}
