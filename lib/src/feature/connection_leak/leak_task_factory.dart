import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/leak_task.dart';

class LeakTaskFactory {
  LeakTaskFactory(int leakDetectionThreshold) {
    _leakDetectionThreshold = leakDetectionThreshold;
  }

  late int _leakDetectionThreshold;

  LeakTask createTask(Db connectionInfo) =>
      LeakTask(connectionInfo, _leakDetectionThreshold);

  void cancelTask(LeakTask proxyLeakTask) {
    proxyLeakTask.cancel();
  }
}
