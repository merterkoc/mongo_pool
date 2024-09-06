import 'package:meta/meta.dart';
import 'package:mongo_pool/mongo_pool.dart';

@immutable
class MongoPoolConfiguration {
  /// Mongo pool configuration.
  ///
  /// [poolSize] is the minimum number of connections in the pool.
  ///
  /// [uriString] is the connection string to the database.
  ///
  /// [maxLifetimeMilliseconds] is the maximum lifetime of a connection in the pool.
  /// Connection pools can dynamically expand when faced with high demand. Unused
  /// connections within a specified period are automatically removed, and the pool
  /// size is reduced to the specified minimum when connections are not reused within
  /// that timeframe.
  ///
  /// If null, then the default is 1800000 milliseconds (30 minutes).
  ///
  /// [leakDetectionThreshold] is the threshold for connection leak detection.
  const MongoPoolConfiguration({
    required this.poolSize,
    required this.uriString,
    this.maxLifetimeMilliseconds,
    this.leakDetectionThreshold,
    this.writeConcern = WriteConcern.acknowledged,
    this.secure = false,
    this.tlsAllowInvalidCertificates = false,
    this.tlsCAFile,
    this.tlsCertificateKeyFile,
    this.tlsCertificateKeyFilePassword,
  })  : assert(poolSize > 0, 'poolSize must be greater than 0'),
        assert(uriString != '', 'uriString must not be empty'),
        assert(
          maxLifetimeMilliseconds == null || maxLifetimeMilliseconds > 0,
          'maxLifetimeMilliseconds must be greater than 0',
        ),
        assert(
          leakDetectionThreshold == null || leakDetectionThreshold > 0,
          'leakDetectionThreshold must be greater than 0',
        ),
        assert(
          maxLifetimeMilliseconds == null ||
              leakDetectionThreshold == null ||
              maxLifetimeMilliseconds > leakDetectionThreshold,
          'maxLifetimeMilliseconds must be greater than leakDetectionThreshold',
        ),
        assert(
          poolSize > 0,
          'poolSize must be greater than 0',
        );

  /// The number of connections in the pool.
  final int poolSize;

  /// The connection string to the database.
  final String uriString;

  /// The maximum lifetime of a connection in the pool.
  final int? maxLifetimeMilliseconds;

  /// The threshold for connection leak detection.
  final int? leakDetectionThreshold;

  /// The write concern to use when opening a connection.
  final WriteConcern writeConcern;

  /// Whether to use TLS for the connection.
  final bool secure;

  /// Whether to allow invalid certificates for the connection.
  final bool tlsAllowInvalidCertificates;

  /// The path to the CA file for the connection.
  final String? tlsCAFile;

  /// The path to the certificate key file for the connection.
  final String? tlsCertificateKeyFile;

  /// The password for the certificate key file for the connection.
  final String? tlsCertificateKeyFilePassword;
}
