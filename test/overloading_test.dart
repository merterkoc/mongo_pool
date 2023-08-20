import 'dart:io';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Overloading test', () {
    const collectionName = 'collection';
    final mongoDbUri = Platform.environment['MONGODB_URI'] ??
        'mongodb://localhost:27017/my_database';
    setUp(
      () async {
        final pool = MongoDbPoolService(
          MongoPoolConfiguration(
            poolSize: 4,
            uriString: mongoDbUri,
            maxLifetimeMilliseconds: 2000,
          ),
        );
        await pool.open();
      },
    );

    test('overloading test', () async {
       final mongoDb = MongoDbPoolService.getInstance();
      final connection = await mongoDb.acquire();

      /// get collection
      final collection = connection.collection(collectionName);
      await collection.find().toList();
      await connection.close();

      final connection2 = await mongoDb.acquire();
      final collection2 = connection2.collection(collectionName);
      await collection2.find().toList();
      await connection2.close();

      final connection3 = await mongoDb.acquire();
      final collection3 = connection3.collection(collectionName);
      await collection3.find().toList();
      await connection3.close();

      final connection4 = await mongoDb.acquire();
      final collection4 = connection4.collection(collectionName);
      await collection4.find().toList();
      await connection4.close();

      final connection5 = await mongoDb.acquire();
      final collection5 = connection5.collection(collectionName);
      await collection5.find().toList();
      await connection5.close();

      final connection6 = await mongoDb.acquire();
      final collection6 = connection6.collection(collectionName);
      await collection6.find().toList();
      await connection6.close();
    });

    test('overloading one connection test', () async {
      final mongoDb = MongoDbPoolService.getInstance();
      final connection = await mongoDb.acquire();

      /// get collection
      final collection = connection.collection(collectionName);
      await collection.find().toList();

      final collection2 = connection.collection(collectionName);
      await collection2.find().toList();

      final collection3 = connection.collection(collectionName);
      await collection3.find().toList();

      final collection4 = connection.collection(collectionName);
      await collection4.find().toList();

      final collection5 = connection.collection(collectionName);
      await collection5.find().toList();

      final connection6 = await mongoDb.acquire();
      final collection6 = connection6.collection(collectionName);
      await collection6.find().toList();
      await connection.close();
    });
  });
}
