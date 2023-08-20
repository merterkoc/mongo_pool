enum LeakTaskState {
  idle,
  running,
  leaked;

  bool get isLeaked => this == LeakTaskState.leaked;

  bool get isRunning => this == LeakTaskState.running;

  bool get isIdle => this == LeakTaskState.idle;
}
