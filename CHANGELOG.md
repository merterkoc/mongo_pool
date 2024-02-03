# 1.4.0

- Mongo dart package version update
- Readme update
- Example code update
- Test code update
- Log messages added
- Connection pools can dynamically expand when faced with high demand. Unused connections within a
  specified period are automatically removed, and the pool size is reduced to the specified minimum
  when connections are not reused within that timeframe.

## 1.3.3-dev.2

- Readme update

## 1.3.3-dev.1

- Mongo dart package version update
- Readme update
- Example code update
- Test code update
- Log messages added
- Connection pools can dynamically expand when faced with high demand. Unused connections within a
  specified period are automatically removed, and the pool size is reduced to the specified minimum
  when connections are not reused within that timeframe.

# 1.3.2

- Mongo dart package version update

# 1.3.1

- Readme update
- Multiple invocation of open method is prevented (For when it is run time more than once with hot
  reload new connection is opened problem)
- Connection leak detection added
- Connection release bug fixed
- Test code update
- Log messages added
- Example code update
- MongoDb Pool now needs to be configured with configuration
- MongoDb Pool configuration added
- Lifetime of connections in the pool can now be set

## 1.3.1-dev.2

- Readme update
- Multiple invocation of open method is prevented (For when it is run time more than once with hot
  reload new connection is opened problem)

## 1.3.1-dev.1

- Readme update
- Test code update
- Log messages added
- Connection leak detection added

# 1.3.0

- Readme update
- Connection release bug fixed
- Test code update
- Log messages added
- Example code update
- Test code update
- MongoDb Pool now needs to be configured with configuration
- MongoDb Pool configuration added
- Lifetime of connections in the pool can now be set

# 1.3.0- dev.3

- Connection release bug fixed

# 1.3.0- dev.2

- Test code update
- Log messages added

# 1.3.0- dev.1

- Readme update
- Example code update
- Test code update
- MongoDb Pool now needs to be configured with configuration
- MongoDb Pool configuration added
- Lifetime of connections in the pool can now be set

# 1.2.0

- Readme update
- Opened connection closes after one use

# 1.1.2

- Readme update
- Mongo dart package version update

# 1.1.1

- Readme update
- Test code update
- Fixed a bug that prevented a new connection from being created when no connection remained

# 1.1.0

- Readme update
- Example code update
- Test code update
- Mongodb srv connection problem solved

# 1.0.5

- Export file update for MongoDbPoolService class

# 1.0.4

- Readme update
- Example code update
- Test code update
- Adding MongoDbPoolService class. The pool is now accessible from anywhere in the project

# 1.0.3

- Readme update
- Example code update
- Fixed the issue where calls made without waiting for connections to open would get an error when
  creating a pool

# 1.0.2

- Readme update

# 1.0.1

- Connections in the pool now open automatically
- Throw error when there is no connection to use in the pool expands by opening new connection

# 1.0.0

- Release 1.0.0
