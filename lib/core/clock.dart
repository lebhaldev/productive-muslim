/// Source of "now", injectable so tests can pin the date.
class Clock {
  const Clock();
  DateTime now() => DateTime.now();
}

class FixedClock extends Clock {
  const FixedClock(this.fixed);
  final DateTime fixed;
  @override
  DateTime now() => fixed;
}
