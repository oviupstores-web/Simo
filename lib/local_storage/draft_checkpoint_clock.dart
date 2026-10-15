/// Orders checkpoints across journeys, even if the device clock moves backward.
/// Seeded from both saved drafts before any new capture; no extra database row.
class DraftCheckpointClock {
  DraftCheckpointClock({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  DateTime? _last;
  void observe(DateTime value) {
    if (_last == null || value.isAfter(_last!)) _last = value.toUtc();
  }

  DateTime next() {
    final wall = _now().toUtc();
    final result = _last != null && !wall.isAfter(_last!) ? _last!.add(const Duration(microseconds: 1)) : wall;
    _last = result;
    return result;
  }
}
