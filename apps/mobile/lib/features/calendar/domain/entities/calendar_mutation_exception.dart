/// Thrown when a calendar mutation is rejected by domain policy
/// (e.g. editing an imported external event that is read-only in MeMy).
class CalendarMutationException implements Exception {
  const CalendarMutationException(this.message);

  final String message;

  @override
  String toString() => 'CalendarMutationException: $message';
}
