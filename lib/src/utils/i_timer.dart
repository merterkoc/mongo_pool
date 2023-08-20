import 'dart:async';

abstract class ITimer {
  void run() {}

  void cancel() {}

  Timer? schedule(int milliseconds);
}
