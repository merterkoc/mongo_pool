import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/model/leak_task_state.dart';
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

  /// Test the MongoDbPool class
  group(
    'Open connection, acquire, release test',
    () {
      test('Open Connection', () async {
        final mongoPool = MongoDbPoolService.getInstance();
        expect(mongoPool.availableConnectionLength, equals(4));
        expect(mongoPool.inUseConnectionLength, equals(0));
        await mongoPool.pool.closeAllConnection();
        expect(mongoPool.availableConnectionLength, equals(0));
        expect(mongoPool.inUseConnectionLength, equals(0));
        await mongoPool.close();
        expect(mongoPool.availableConnectionLength, equals(0));
      });
      test('Acquire - release connection', () async {
        final mongoPool = MongoDbPoolService.getInstance();
        final connection = await mongoPool.acquire();
        expect(mongoPool.availableConnectionLength, equals(3));
        expect(mongoPool.inUseConnectionLength, equals(1));
        mongoPool.release(connection);
        expect(mongoPool.availableConnectionLength, equals(4));
        expect(mongoPool.inUseConnectionLength, equals(0));
        await mongoPool.close();
        expect(mongoPool.availableConnectionLength, equals(0));
      });
      test('Leak state test', () async {
        final mongoPool = MongoDbPoolService.getInstance();
        final connection = await mongoPool.acquire();
        final connection2 = await mongoPool.acquire();

        final currentRunningTaskLength = mongoPool.pool.allConnections
            .where((element) => element.leakTask.state == LeakTaskState.running)
            .length;
        expect(currentRunningTaskLength, equals(2));

        expect(mongoPool.availableConnectionLength, equals(2));
        expect(mongoPool.inUseConnectionLength, equals(2));
        mongoPool.release(connection);
        expect(mongoPool.availableConnectionLength, equals(3));
        expect(mongoPool.inUseConnectionLength, equals(1));

        mongoPool.release(connection2);
        expect(mongoPool.availableConnectionLength, equals(4));
        expect(mongoPool.inUseConnectionLength, equals(0));

        final currentIdleTaskLength = mongoPool.pool.allConnections
            .where((element) => element.leakTask.state == LeakTaskState.idle)
            .length;
        expect(currentIdleTaskLength, equals(4));
      });
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}
