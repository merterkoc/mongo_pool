# MongoDB Connection Pooling - Mongo Pool

## How to migrate from 1.2.0 to 1.3.0

* To use MongoDb PoolService you need to create a new Mongo Pool Configuration object. You can use
  the following code
  snippet to create a Mongo Pool Configuration object.

```dart

final MongoDbPoolService poolService = MongoDbPoolService(
  const MongoPoolConfiguration(
    maxLifetimeMilliseconds: 1000,
    uriString: 'mongodb://localhost:27017/my_database',
    poolSize: 4,
  ),
);
```

* You can use the following code snippet to open the pool.

```dart

await openDbPool(poolService);

Future<void> openDbPool(MongoDbPoolService service) async {
  try {
    await service.open();
  } on Exception catch (e) {
    /// handle the exception here
    print(e);
  }
}

```

* You can use the following code snippet to get the instance of the pool.

```dart

final MongoDbPoolService poolService = MongoDbPoolService.getInstance();
```

## Introduction

This package is a simple connection pooling for MongoDB. It is based on
the [mongo_dart](https://pub.dartlang.org/packages/mongo_dart) package.

## Features

* Connection pool size configuration
* Automatic connection pool expansion
* Instance where you can access the connection from the pool [NEW]

## Getting started

Using this package, your application will open as many database connections as you specify as soon
as it runs. You can
open, close and change the number of these links at any time.

## Usage

With mongodb package, you can use the `MongoDbPoolService` class to create a pool of connections.

First, you need to create a `MongoDbPoolService` instance. You can do this by passing the number of
connections you want
Next, you need to open the pool. You can do this by calling the `open()` method. If you want to
close the pool, you can
call the `close()` method.
`MongoDbPoolService` class has a `getInstance()` method. You can use this method to get the instance
of the pool.
You can use this instance to access the pool from anywhere in the project.

A simple usage example:

```dart

import 'package:mongo_pool/mongo_pool.dart';

Future<void> main() async {
  /// Create a pool of 5 connections
  final MongoDbPoolService poolService = MongoDbPoolService(
    const MongoPoolConfiguration(
      maxLifetimeMilliseconds: 1000,
      uriString: 'mongodb://localhost:27017/my_database',
      poolSize: 4,
    ),
  );

  /// Open the pool
  await openDbPool(poolService);

  /// Get a connection from pool
  final Db connection = await poolService.acquire();

  // Database operations
  final DbCollection collection = connection.collection('my_collection');
  final List<Map<String, dynamic>> result = await collection.find().toList();
  result;
  // Connection release for other operations
  unawaited(poolService.release(connection));

  // Pool close
  await poolService.close();
}

Future<void> openDbPool(MongoDbPoolService service) async {
  try {
    await service.open();
  } on Exception catch (e) {
    /// handle the exception here
    print(e);
  }
}

class OtherClass {
  OtherClass();

  Future<void> openDbPool() async {
    /// Get the instance of the pool
    final MongoDbPoolService poolService = MongoDbPoolService.getInstance();
    final Db connection = await poolService.acquire();
    // Database operations
    final DbCollection collection = connection.collection('my_collection');
    final List<Map<String, dynamic>> result = await collection.find().toList();
    result;
    // Connection release for other operations
    poolService.release(connection);
    // Pool close
    await poolService.close();
  }
}


```

## Testing

To run the tests, you need to have a MongoDB instance running on your machine. You can use the
following command to
start a MongoDB instance using Docker:

```bash
docker run -d -p 27017:27017 --name mongo mongo
```

## Problems Solved

- [x] Mongodb srv connection problem solved
- [x] Fixed a bug that prevented a new connection from being created when no connection remained
- [x] Unable to connect to MongoDB using SSL/TLS fixed

## Get package for using in your project

[![pub package](https://img.shields.io/pub/v/mongo_pool.svg)](https://pub.dev/packages/mongo_pool)  
[Show in pub.dev](https://pub.dev/packages/mongo_pool)

## Additional information

mertyasarerkocc@gmail.com




