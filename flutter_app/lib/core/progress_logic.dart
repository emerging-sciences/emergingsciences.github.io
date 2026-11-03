// Study progress helpers (pure Dart).

String dayKey(DateTime d) {
  final m = d.month < 10 ? '0${d.month}' : '${d.month}';
  final dd = d.day < 10 ? '0${d.day}' : '${d.day}';
  return '${d.year}-$m-$dd';
}

/// Number of consecutive days (ending today, or yesterday if today's goal is not met yet)
/// on which at least [goalSeconds] were studied.
int studyStreak(Map<String, int> study, int goalSeconds, DateTime now) {
  var n = 0;
  var d = DateTime(now.year, now.month, now.day);
  if ((study[dayKey(d)] ?? 0) < goalSeconds) {
    d = DateTime(d.year, d.month, d.day - 1);
  }
  while ((study[dayKey(d)] ?? 0) >= goalSeconds && goalSeconds > 0) {
    n++;
    d = DateTime(d.year, d.month, d.day - 1);
  }
  return n;
}
