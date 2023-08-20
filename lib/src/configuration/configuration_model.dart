import 'package:meta/meta.dart';

@immutable
class MongoPoolConfiguration {
  /// Mongo pool configuration.
  ///
  /// [poolSize] is the number of connections in the pool.
  ///
  /// [uriString] is the connection string to the database.
  ///
  /// [maxLifetimeMilliseconds] is the maximum lifetime of a connection in the pool.
  ///
  /// [leakDetectionThreshold] is the threshold for connection leak detection.
  const MongoPoolConfiguration({
    required this.poolSize,
    required this.uriString,
    this.maxLifetimeMilliseconds,
    this.leakDetectionThreshold,
  })  : assert(poolSize > 0, 'poolSize must be greater than 0'),
        assert(uriString != '', 'uriString must not be empty'),
        assert(
          maxLifetimeMilliseconds == null || maxLifetimeMilliseconds > 0,
          'maxLifetimeMilliseconds must be greater than 0',
        ),
        assert(
          leakDetectionThreshold == null || leakDetectionThreshold > 0,
          'leakDetectionThreshold must be greater than 0',
        );

  /// The number of connections in the pool.
  final int poolSize;

  /// The connection string to the database.
  final String uriString;

  /// The maximum lifetime of a connection in the pool.
  final int? maxLifetimeMilliseconds;

  /// The threshold for connection leak detection.
  final int? leakDetectionThreshold;
}
