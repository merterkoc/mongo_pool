abstract class IMongoPoolException implements Exception {
  String get message;
}

class NotInitializedMongoPoolException implements IMongoPoolException {
  @override
  String get message => 'MongoPool is not initialized';
}