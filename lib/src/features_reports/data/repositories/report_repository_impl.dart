import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/ai_parser_datasource.dart';
import '../datasources/local_sqlite_datasource.dart';
import '../datasources/remote_api_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final RemoteApiDataSource remoteDataSource;
  final AiParserDataSource aiDataSource;
  final LocalSqliteDataSource localDataSource;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.aiDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ReportEntity>> getSmartReports() async {
    try {
      // 1. Consume API externa densa vía Dio
      final rawDenseJson = await remoteDataSource.fetchDenseTrafficReport();

      // 2. Filtra e integra el Smart Data Parsing con Gemini
      final cleanJson = await aiDataSource.cleanJsonWithGemini(rawDenseJson);

      // 3. Respalda localmente en SQLite para soporte Offline
      await localDataSource.cacheReport(cleanJson);

      return [ReportEntity.fromJson(cleanJson)];
    } catch (e) {
      // 4. FALLBACK OFFLINE: Si no hay red, lee directo de la base local
      final localReports = await localDataSource.getCachedReports();
      if (localReports.isNotEmpty) {
        return localReports.map((json) => ReportEntity.fromJson(json)).toList();
      }
      throw Exception(
        "Sin conexión a internet y sin respaldos en la base de datos.",
      );
    }
  }
}
