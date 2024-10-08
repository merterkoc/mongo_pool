import 'dart:async';

import 'package:mongo_pool/mongo_pool.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final MongoDbPoolService poolService = MongoDbPoolService(
    const MongoPoolConfiguration(
      maxLifetimeMilliseconds: 90000,
      leakDetectionThreshold: 10000,
      uriString: 'mongodb://localhost:27017/my_database',
      poolSize: 4,
      secure: false,
      tlsAllowInvalidCertificates: false,
      tlsCAFile: null,
      tlsCertificateKeyFile: null,
      tlsCertificateKeyFilePassword: null,
      writeConcern: WriteConcern.acknowledged,
    ),
  );

  /// Initialize the pool
  await initialize(poolService);

  /// Get a connection from pool
  final Db connection = await poolService.acquire();

  // Database operations
  final DbCollection collection = connection.collection('my_collection');
  final List<Map<String, dynamic>> result = await collection.find().toList();
  result;
  // Connection release for other operations
  poolService.release(connection);

  // Pool close
  await poolService.close();
}

Future<void> initialize(MongoDbPoolService service) async {
  try {
    await service.initialize();
  } on Exception catch (e) {
    /// handle the exception here
    print(e);
  }
}

class OtherClass {
  OtherClass();

  Future<void> openDbPool() async {
    /// Get the instance of the pool
    final MongoDbPoolService poolService = MongoDbPoolService.getInstance();
    final Db connection = await poolService.acquire();
    // Database operations
    final DbCollection collection = connection.collection('my_collection');
    final List<Map<String, dynamic>> result = await collection.find().toList();
    result;
    // Connection release for other operations
    poolService.release(connection);
    // Pool close
    await poolService.close();
  }
}
