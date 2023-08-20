import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/utils/i_timer.dart';

class ProxyLeakTask implements ITimer {
  ProxyLeakTask(this.connection, this.leakDetectionThreshold) {
    schedule(leakDetectionThreshold);
  }

  late final Db connection;

  /// if [leakDetectionThreshold] is null, no timer is created and the callback
  /// is executed
  late final int leakDetectionThreshold;

  late Timer _timer;

  bool isLeaked = false;

  @override
  void cancel() {
    if (isLeaked) {
      log('Previously reported leaked connection is closed');
    }
    _timer.cancel();
  }

  @override
  Future<void> run() async {
    isLeaked = true;
    final buffer = StringBuffer()
      ..writeln(
        'Connection leak detected' ' after $leakDetectionThreshold ms',
      )
      ..writeln('Leak stack trace:')
      ..writeln(StackTrace.current)
      ..writeln('Leak create time: ${DateTime.now()}')
      ..writeln('Leak connection state: ${connection.state}');
    connection.state != State.closed || connection.state != State.closing
        ? await connection.close()
        : log('Connection is already closed');
    log(buffer.toString());
    _timer.cancel();
    throw StateError(buffer.toString());
  }

  /// [milliseconds] must a non-negative [Duration].
  /// If [milliseconds] is zero, no timer is created and the callback is executed
  @override
  Timer schedule(int milliseconds) {
    return _timer = Timer(Duration(milliseconds: milliseconds), run);
  }
}
