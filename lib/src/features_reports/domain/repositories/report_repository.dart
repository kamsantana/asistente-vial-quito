import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<List<ReportEntity>> getSmartReports();
}
