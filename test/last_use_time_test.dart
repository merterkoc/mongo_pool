import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  final mongoDbUri = Platform.environment['MONGODB_URI'] ??
      'mongodb://localhost:27017/my_database';
  setUpAll(
    () async {
      final pool = MongoDbPoolService(
        MongoPoolConfiguration(
          poolSize: 2,
          uriString: mongoDbUri,
          maxLifetimeMilliseconds: 3000,
        ),
      );
      await pool.initialize();
    },
  );

  /// Test the MongoDbPool class
  group(
    'Connection last in use time test',
    () {
      test('Test 1', () async {
        final mongoPool = MongoDbPoolService.getInstance();
        final connection = await mongoPool.acquire();
        mongoPool.release(connection);
        expect(mongoPool.pool.allConnections.last.inUse, equals(false));
        expect(
          DateTime.now().difference(
                mongoPool.pool.allConnections.last.lastUseTime,
              ) <
              const Duration(seconds: 1),
          equals(true),
        );
        await Future<void>.delayed(const Duration(seconds: 3));
        expect(
          DateTime.now().difference(
                mongoPool.pool.allConnections.last.lastUseTime,
              ) <
              const Duration(seconds: 1),
          equals(false),
        );
      });
      test('Connection size test', () async {
        final mongoPool = MongoDbPoolService.getInstance();

        final connection = await mongoPool.acquire();
        final connection2 = await mongoPool.acquire();
        final connection3 = await mongoPool.acquire();
        final connection4 = await mongoPool.acquire();
        mongoPool
          ..release(connection)
          ..release(connection2)
          ..release(connection3)
          ..release(connection4);

        expect(mongoPool.pool.allConnections.length, equals(4));
        await Future<void>.delayed(const Duration(seconds: 4));
        expect(mongoPool.pool.allConnections.length, equals(2));
        await mongoPool.close();
      });
    },
    timeout: const Timeout(Duration(seconds: 50)),
  );
}
