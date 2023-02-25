import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/test.dart';

void main() {
  /// Test the MongoDbPool class
  group('MongoDbPool tests', () {
    late MongoDbPool pool;

    setUp(() {
      /// Create a pool of 2 connections
      pool = MongoDbPool(2, 'mongodb://localhost:27017/station_center');
    });

    test('Acquire and release connections', () async {
      final conn1 = await pool.acquire();
      final conn2 = await pool.acquire();
      expect(pool.available.length, equals(0));
      expect(pool.inUse.length, equals(2));
      pool.release(conn1);
      expect(pool.available.length, equals(1));
      expect(pool.inUse.length, equals(1));
      pool.release(conn2);
      expect(pool.available.length, equals(2));
      expect(pool.inUse.length, equals(0));
    });

    test('No connection available', () async {
      final conn1 = await pool.acquire();
      final conn2 = await pool.acquire();
      expect(pool.available.length, equals(0));
      expect(pool.inUse.length, equals(2));
      final conn3 = await pool.acquire();
      expect(conn3.state, equals(State.open));
      expect(pool.available.length, equals(0));
      pool.release(conn3);
      expect(pool.available.length, equals(1));
    });

    test('Close pool', () async {
      final conn1 = await pool.acquire();
      final conn2 = await pool.acquire();
      expect(pool.available.length, equals(0));
      expect(pool.inUse.length, equals(2));
      await pool.close();
      expect(pool.available.length, equals(0));
      expect(pool.inUse.length, equals(0));
      expect(conn1.state, equals(State.closed));
      expect(conn2.state, equals(State.closed));
    });
  });
}
