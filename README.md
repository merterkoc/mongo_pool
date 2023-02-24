# MongoDB Connection Pooling - Mongo Pool

## Introduction

This package is a simple connection pooling for MongoDB. It is based on
the [mongo_dart](https://pub.dartlang.org/packages/mongo_dart) package.

## Features

* Connection pool size configuration

## Getting started

Using this package, your application will open as many database connections as you specify as soon as it runs. You can
open, close and change the number of these links at any time.

## Usage

With mongodb package, you can use the `MongoDbPool` class to create a pool of connections.

A simple usage example:

```dart
import 'package:mongo_pool/mongo_pool.dart';

Future<void> main() async {
  final pool = MongoDbPool(5, 'mongodb://localhost:27017/my_database');
  final conn = await pool.acquire();

  // Database operations
  final collection = conn.collection('my_collection');
  final result = await collection.find().toList();

  // Connection release for other operations
  pool.release(conn);

  // Pool close
  await pool.close();
}

```

### Testing

To run the tests, you need to have a MongoDB instance running on your machine. You can use the following command to
start a MongoDB instance using Docker:

```bash
docker run -d -p 27017:27017 --name mongo mongo
```

or you can install MongoDB on your machine.

## Get package for using in your project

[![pub package](https://img.shields.io/pub/v/mongo_pool.svg)](https://pub.dev/packages/mongo_pool)  
[Show in pub.dev](https://pub.dev/packages/mongo_pool)




## Additional information

mertyasarerkocc@gmail.com




