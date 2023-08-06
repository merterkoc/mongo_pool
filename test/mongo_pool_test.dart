import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/configuration/configuration_model.dart';
import 'package:test/test.dart';

@Timeout(Duration(seconds: 120))
void main() {
  /// Test the MongoDbPool class
  group(
    'MongoDbPool test 1 connection',
    () {
      const uriString =
          'mongodb+srv://client:5TiGAZaBLYbrU5je@cluster0.ltybqen.mongodb.net/?retryWrites=true&w=majority/station_center';
      setUp(() {
        /// Create a pool of 1 connections
      });
      test('Open pool', () async {
        final mongoDb = await MongoDbPoolService(
          const MongoPoolConfiguration(
            poolSize: 4,
            uriString: uriString,
            maxLifetimeMilliseconds: 2000,
          ),
        ).open();
        await Future<void>.delayed(const Duration(seconds: 100));

        expect(mongoDb.available.length, equals(1));
        expect(mongoDb.inUse.length, equals(0));
        await mongoDb.close();
      });
    },
    timeout: const Timeout(Duration(seconds: 120)),
  );
}
