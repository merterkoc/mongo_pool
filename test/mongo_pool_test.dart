import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  /// Test the MongoDbPool class
  group('MongoDbPool test 1 connection', () {
    final uriString =
        'mongodb+srv://client:5TiGAZaBLYbrU5je@cluster0.ltybqen.mongodb.net/?retryWrites=true&w=majority/station_center';
    setUp(() {
      /// Create a pool of 1 connections
    });
    test('Open pool', () async {
      final mongoDb =
          await MongoDbPoolService(poolSize: 1, mongoDbUri: uriString).open();
      expect(mongoDb.available.length, equals(0));
      expect(mongoDb.inUse.length, equals(2));
      await mongoDb.close();
    });
  });
}
