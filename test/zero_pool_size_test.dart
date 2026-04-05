import 'dart:async';
import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  final mongoDbUri = Platform.environment['MONGODB_URI'] ??
      'mongodb://localhost:27017/my_database';

  group('Zero pool size tests', () {
    late MongoDbPoolService poolService;

    setUp(() async {
      poolService = MongoDbPoolService(
        MongoPoolConfiguration(
          poolSize: 0,
          uriString: mongoDbUri,
        ),
      );
      await poolService.initialize();
    });

    tearDown(() async {
      await poolService.close();
    });

    test('Initialize, acquire and release single connection', () async {
      expect(poolService.availableConnectionLength, equals(0));
      expect(poolService.inUseConnectionLength, equals(0));

      final connection = await poolService.acquire();

      expect(poolService.availableConnectionLength, equals(0));
      expect(poolService.inUseConnectionLength, equals(1));

      poolService.release(connection);

      expect(poolService.availableConnectionLength, equals(1));
      expect(poolService.inUseConnectionLength, equals(0));
    });

    test('Multiple acquire creates multiple connections', () async {
      final connections = await Future.wait([
        poolService.acquire(),
        poolService.acquire(),
        poolService.acquire(),
      ]);

      expect(poolService.inUseConnectionLength, equals(3));
      expect(poolService.availableConnectionLength, equals(0));

      for (final conn in connections) {
        poolService.release(conn);
      }

      expect(poolService.inUseConnectionLength, equals(0));
      expect(poolService.availableConnectionLength, equals(3));
    });

    test('Released connection should be reused', () async {
      final conn1 = await poolService.acquire();
      poolService.release(conn1);

      final conn2 = await poolService.acquire();

      expect(identical(conn1, conn2), isTrue);
    });

    test('Double release should throw exception', () async {
      final conn = await poolService.acquire();
      poolService.release(conn);

      expect(
        () => poolService.release(conn),
        throwsA(isA<Exception>()),
      );
    });

    test('Stress test with repeated acquire/release', () async {
      for (var i = 0; i < 50; i++) {
        final conn = await poolService.acquire();
        poolService.release(conn);
      }

      expect(poolService.inUseConnectionLength, equals(0));
      expect(poolService.availableConnectionLength, greaterThan(0));
    });

    test('Concurrent acquire and release stability', () async {
      final futures = List.generate(20, (_) async {
        final conn = await poolService.acquire();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        poolService.release(conn);
      });

      await Future.wait(futures);

      expect(poolService.inUseConnectionLength, equals(0));
      expect(poolService.availableConnectionLength, greaterThan(0));
    });
  });
}
