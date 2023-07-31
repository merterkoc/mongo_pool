  class MongoPoolConfiguration {
  final int poolSize;
  final String uriString;
  final int maxLifetimeMilliseconds;

  const MongoPoolConfiguration(
      {required this.poolSize, required this.uriString, required this.maxLifetimeMilliseconds})
      : assert(poolSize > 0, 'poolSize must be greater than 0'),
        assert(uriString != '', 'uriString must not be empty'),
        assert(maxLifetimeMilliseconds > 0,
            'maxLifetimeMilliseconds must be greater than 0');
}
