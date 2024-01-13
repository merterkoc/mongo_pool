import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/leak_task.dart';

class ConnectionInfo {
  ConnectionInfo(
    this.connection, {
    required this.lastUseTime,
    required this.leakTask,
  }) {
    createTime = DateTime.now();
  }

  Db connection;
  late final DateTime createTime;
  DateTime lastUseTime;
  late final LeakTask leakTask;

  /// Connection last used time
  DateTime get lastUse => lastUseTime;

  bool get inUse => leakTask.state.isRunning;

  bool get isLeaked => leakTask.state.isLeaked;

  bool get isIdle => leakTask.state.isIdle;
}
