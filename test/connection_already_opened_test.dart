import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/exception/exception.dart';
import 'package:test/test.dart';

void main() {
  final mongoDbUri = Platform.environment['MONGODB_URI'] ??
      'mongodb://localhost:27017/my_database';
  setUp(
    () async {
      final pool = MongoDbPoolService(
        MongoPoolConfiguration(
          poolSize: 4,
          uriString: mongoDbUri,
          maxLifetimeMilliseconds: 10000,
        ),
      );
      await pool.initialize();
    },
  );

  group('Connection already opened test', () {
    /// Test the MongoDbPoolService class
    test('Open pool', () async {
      final mongoDb = MongoDbPoolService.getInstance();
      try {
        await mongoDb.initialize();
      } on PoolAlreadyOpenMongoPoolException catch (e) {
        expect(e.message, equals('Pool is already open'));
      }
    });
  });
}
