import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/proxy_leak_task.dart';

class ProxyLeakTaskFactory {
  ProxyLeakTaskFactory(int leakDetectionThreshold) {
    _leakDetectionThreshold = leakDetectionThreshold;
  }

  late int _leakDetectionThreshold;

  ProxyLeakTask scheduleNewTask(Db connectionInfo) {
    return ProxyLeakTask(connectionInfo, _leakDetectionThreshold);
  }

  void cancelTask(ProxyLeakTask proxyLeakTask) {
    proxyLeakTask.cancel();
  }
}
