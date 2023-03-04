import 'package:mongo_pool/mongo_pool.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final pool = MongoDbPool(5, 'mongodb://localhost:27017/my_database');
  /// Open the pool
  await pool.open();
  /// Get a connection from pool
  final conn = await pool.acquire();

  // Database operations
  final collection = conn.collection('my_collection');
  final result = await collection.find().toList();
  // Connection release for other operations
  pool.release(conn);

  // Pool close
  await pool.close();
}
