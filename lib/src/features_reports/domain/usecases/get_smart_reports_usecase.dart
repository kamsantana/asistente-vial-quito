import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

class GetSmartReportsUseCase {
  final ReportRepository repository;

  GetSmartReportsUseCase(this.repository);

  Future<List<ReportEntity>> call() async {
    return await repository.getSmartReports();
  }
}
