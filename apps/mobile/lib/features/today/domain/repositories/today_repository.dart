import '../entities/today_summary.dart';

abstract class TodayRepository {
  Future<TodaySummary> fetchTodaySummary();
}
