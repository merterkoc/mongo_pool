import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  /// Test the MongoDbPool class
  group(
    'MongoDbPool test 1 connection',
    () {
      const uriString =
          'connectionString';
      setUp(() {
        /// Create a pool of 1 connections
      });
      test('Open pool', () async {
        final mongoDb = await MongoDbPoolService(
          const MongoPoolConfiguration(
            poolSize: 4,
            uriString: uriString,
            maxLifetimeMilliseconds: 40000,
          ),
        ).open();
        await Future<void>.delayed(const Duration(seconds: 10));

        expect(mongoDb.available.length, equals(4));
        expect(mongoDb.inUse.length, equals(0));
        await mongoDb.closeAllConnection();
      });
    },
    timeout: const Timeout(Duration(seconds: 120)),
  );
}
