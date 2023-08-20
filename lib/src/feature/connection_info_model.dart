import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/proxy_leak_task.dart';

class ConnectionInfo {
  ConnectionInfo(
    this.connection, {
    required this.lastUseTime,
    required this.proxyLeakTask,
  }) {
    createTime = DateTime.now();
  }

  Db connection;
  late final DateTime createTime;
  DateTime lastUseTime;
  late final ProxyLeakTask proxyLeakTask;

  /// Connection last used time
  DateTime get lastUse => lastUseTime;

  /// Last time the connection was used.
  set lastUse(DateTime time) => lastUseTime = time;
}
