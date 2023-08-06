import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  /// Test the MongoDbPool class

  group('MongoDbPool test 2 connection', () {
    const uriString =
        'connectionString';
    setUp(() {
      /// Create a pool of 2 connections
    });

    /// Test the MongoDbPoolService class
    test('Open pool', () async {
      final mongoDb = await MongoDbPoolService(
        const MongoPoolConfiguration(
          poolSize: 2,
          uriString: uriString,
          maxLifetimeMilliseconds: 900000,
        ),
      ).open();
      final conn1 = await mongoDb.acquire();
      final conn2 = await mongoDb.acquire();
      await Future<void>.delayed(const Duration(seconds: 10));
      expect(mongoDb.available.length, equals(0));
      expect(mongoDb.inUse.length, equals(2));
      mongoDb.release(conn1);
      expect(mongoDb.inUse.length, equals(1));
      mongoDb.release(conn2);
      // expect(mongoDb.available.length, equals(2));
      // expect(mongoDb.inUse.length, equals(0));
      // await mongoDb.close();
      // expect(mongoDb.available.length, equals(0));
      // expect(mongoDb.inUse.length, equals(0));
      // expect(conn1.state, equals(State.closed));
      // expect(conn2..state, equals(State.closed));
      // final mongoDb2 = MongoDbPoolService.getInstance();
      // expect(mongoDb2, isNotNull);
      // expect(mongoDb2.config.poolSize, equals(2));
      // expect(mongoDb2.config.uriString, equals(uriString));
      // expect(mongoDb2.config.uriString, equals(uriString));
      // expect(mongoDb2.pool.available.length, equals(mongoDb.available.length));
      // expect(mongoDb2.pool.inUse.length, equals(mongoDb.inUse.length));
      // expect(mongoDb2.pool.hashCode, equals(mongoDb.hashCode));
    });
  });
}
