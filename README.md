# MongoDB Connection Pooling - Mongo Pool

## Introduction

This package is a simple connection pooling for MongoDB. It is based on
the [mongo_dart](https://pub.dartlang.org/packages/mongo_dart) package.

## Features

* Connection pool size configuration
* Automatic connection pool expansion
* Instance where you can access the connection from the pool [NEW]

## Getting started

Using this package, your application will open as many database connections as you specify as soon as it runs. You can
open, close and change the number of these links at any time.

## Usage

With mongodb package, you can use the `MongoDbPool` class to create a pool of connections.

A simple usage example:

```dart
import 'package:mongo_pool/src/mongo_pool_service.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final poolService = MongoDbPoolService(
    poolSize: 5,
    mongoDbUri: 'mongodb://localhost:27017/my_database',
  );

  /// Open the pool
  openDbPool(poolService);

  /// Get a connection from pool
  final conn = await poolService.acquire();

  // Database operations
  final collection = conn.collection('my_collection');
  final result = await collection.find().toList();
  // Connection release for other operations
  poolService.release(conn);

  // Pool close
  await poolService.close();
}

Future<void> openDbPool(MongoDbPoolService service) async {
  try {
    await service.open();
  } on Exception catch (e) {
    /// handle the exception here
    print(e.toString());
  }
}

class OtherClass {
  OtherClass();

  Future<void> openDbPool() async {
    /// Get the instance of the pool
    /// Once you define MongoDbPoolService you can call it with getInstance() method
    final poolService = MongoDbPoolService.getInstance();
    final conn = await poolService.acquire();
    // Database operations
    final collection = conn.collection('my_collection');
    final result = await collection.find().toList();
    // Connection release for other operations
    poolService.release(conn);
    // Pool close
    await poolService.close();
  }
}

```

## Testing

To run the tests, you need to have a MongoDB instance running on your machine. You can use the following command to
start a MongoDB instance using Docker:

```bash
docker run -d -p 27017:27017 --name mongo mongo
```

## Problems Solved

- [x] Fixed the issue where calls made without waiting for connections to open would get an error when creating a pool. Please see example codes
- [x] Throw error when there is unable to connect to the database
## Get package for using in your project

[![pub package](https://img.shields.io/pub/v/mongo_pool.svg)](https://pub.dev/packages/mongo_pool)  
[Show in pub.dev](https://pub.dev/packages/mongo_pool)

## Additional information

mertyasarerkocc@gmail.com




