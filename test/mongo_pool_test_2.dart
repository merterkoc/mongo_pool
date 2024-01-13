import 'dart:async';
import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
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
      await pool.open();
    },
  );

  group('MongoDbPool test 2 connection', () {
    /// Test the MongoDbPoolService class
    test('Open pool', () async {
      final mongoDb = MongoDbPoolService.getInstance();
      expect(mongoDb.availableConnectionLength, equals(4));
      final conn1 = await mongoDb.acquire();
      final conn2 = await mongoDb.acquire();
      expect(mongoDb.availableConnectionLength, equals(2));
      expect(mongoDb.inUseConnectionLength, equals(2));
      mongoDb.release(conn1);
      expect(mongoDb.inUseConnectionLength, equals(1));
      mongoDb.release(conn2);
      await mongoDb.acquire();
      await Future<void>.delayed(const Duration(seconds: 10));
    });
  });
}
