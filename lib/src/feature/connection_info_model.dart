import 'package:mongo_pool/mongo_pool.dart';

class ConnectionInfo {
  ConnectionInfo(this.connection)
      : createTime = DateTime.now(),
        lastUseTime = DateTime.now();
  Db connection;
  DateTime createTime;
  DateTime lastUseTime;
}
