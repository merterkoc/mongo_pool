import 'package:mongo_pool/mongo_pool.dart';

class ConnectionInfo {
  Db connection;
  DateTime createTime;
  DateTime lastUseTime;

  ConnectionInfo(this.connection)
      : createTime = DateTime.now(),
        lastUseTime = DateTime.now();
}
