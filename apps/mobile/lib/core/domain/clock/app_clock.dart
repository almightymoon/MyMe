/// Injectable clock so Habit scheduling/streaks stay deterministic in tests.
abstract interface class AppClock {
  DateTime now();
}

class SystemAppClock implements AppClock {
  const SystemAppClock();

  @override
  DateTime now() => DateTime.now();
}

class FixedAppClock implements AppClock {
  FixedAppClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void setNow(DateTime value) => _now = value;
}
