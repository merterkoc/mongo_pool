import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  final mongoDbUri = Platform.environment['MONGODB_URI'] ??
      'mongodb://localhost:27017/my_database';

  group('Health Check Tests', () {
    test('Health check enabled by default', () async {
      final config = MongoPoolConfiguration(
        poolSize: 2,
        uriString: mongoDbUri,
      );

      expect(config.enableHealthCheck, isTrue);
      expect(config.healthCheckTimeoutMs, equals(5000));
    });

    test('Health check can be disabled', () async {
      final config = MongoPoolConfiguration(
        poolSize: 2,
        uriString: mongoDbUri,
        enableHealthCheck: false,
      );

      expect(config.enableHealthCheck, isFalse);
    });

    test('Custom health check timeout', () async {
      final config = MongoPoolConfiguration(
        poolSize: 2,
        uriString: mongoDbUri,
        healthCheckTimeoutMs: 3000,
      );

      expect(config.healthCheckTimeoutMs, equals(3000));
    });

    test('Acquire connection with health check enabled', () async {
      final pool = MongoDbPoolService(
        MongoPoolConfiguration(
          poolSize: 2,
          uriString: mongoDbUri,
        ),
      );

      await pool.initialize();

      // Acquire a connection - this should trigger health check
      final connection = await pool.acquire();
      expect(connection, isNotNull);
      expect(pool.availableConnectionLength, equals(1));
      expect(pool.inUseConnectionLength, equals(1));

      pool.release(connection);
      expect(pool.availableConnectionLength, equals(2));
      expect(pool.inUseConnectionLength, equals(0));

      await pool.close();
    });

    test('Acquire connection with health check disabled', () async {
      final pool = MongoDbPoolService(
        MongoPoolConfiguration(
          poolSize: 2,
          uriString: mongoDbUri,
          enableHealthCheck: false,
        ),
      );

      await pool.initialize();

      // Acquire a connection - health check should be skipped
      final connection = await pool.acquire();
      expect(connection, isNotNull);
      expect(pool.availableConnectionLength, equals(1));
      expect(pool.inUseConnectionLength, equals(1));

      pool.release(connection);
      await pool.close();
    });
  }, timeout: const Timeout(Duration(seconds: 30)));
}
