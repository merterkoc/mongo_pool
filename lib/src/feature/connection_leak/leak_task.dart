import 'dart:async';
import 'dart:developer';

import 'package:mongo_pool/mongo_pool.dart';
import 'package:mongo_pool/src/feature/connection_leak/model/leak_task_state.dart';
import 'package:mongo_pool/src/utils/i_timer.dart';

class LeakTask implements ITimer {
  LeakTask(this.connection, this.leakDetectionThreshold) {
    state = LeakTaskState.idle;
  }

  late final Db connection;

  /// if [leakDetectionThreshold] is null, no timer is created and the callback
  /// is executed
  late final int leakDetectionThreshold;

  Timer? _timer;

  LeakTaskState state = LeakTaskState.idle;

  /// start the timer whenever the connection is used
  void start() => schedule(leakDetectionThreshold);

  @override
  void cancel() {
    /// if limit is empty or 0 timer is not initialized
    /// so no need to cancel it
    if (leakDetectionThreshold == 0) {
      state = LeakTaskState.idle;

      /// if timer is not initialized, no need to cancel it
      return;
    } else if (state.isLeaked) {
      log('Previously reported leaked connection is closed');
    }

    if (state.isRunning) state = LeakTaskState.idle;
    if (_timer != null) _timer?.cancel();
  }

  @override
  Future<void> run() async {
    state = LeakTaskState.leaked;
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
    _timer?.cancel();
    throw StateError(buffer.toString());
  }

  /// [milliseconds] must a non-negative [Duration].
  /// If [milliseconds] is zero, no timer is created and the callback is executed
  @override
  Timer? schedule(int milliseconds) {
    state = LeakTaskState.running;
    return leakDetectionThreshold == 0
        ? null
        : _timer = Timer(Duration(milliseconds: milliseconds), run);
  }
}
