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
      // 1. Consumimos la lista completa de reportes desde Cloud Firestore
      final List<Map<String, dynamic>> rawReportsList = await remoteDataSource
          .fetchDenseTrafficReportsList();

      List<ReportEntity> listaFinal = [];

      // 2. Procesamos cada reporte de la lista de forma dinámica
      for (var rawReport in rawReportsList) {
        Map<String, dynamic> cleanJson = rawReport;

        // Si el reporte viene directo de la API densa o requiere parsing de Gemini, se procesa.
        // Si ya fue pre-procesado en el formulario, lo pasamos directo.
        if (rawReport['resumen_ia'] ==
            'Reporte manual ingresado por el conductor en escena.') {
          cleanJson = rawReport;
        } else {
          // Filtrado e integración en tiempo real con Gemini para reportes externos/crudos
          cleanJson = await aiDataSource.cleanJsonWithGemini(rawReport);
        }

        // 3. Respaldo local de cada reporte individual en SQLite para soporte Offline
        await localDataSource.cacheReport(cleanJson);

        // 4. Transformamos usando tu factory oficial .fromJson
        listaFinal.add(ReportEntity.fromJson(cleanJson));
      }

      return listaFinal;
    } catch (e) {
      print("⚠️ Error en red/Firestore, activando FALLBACK OFFLINE: $e");

      // 5. FALLBACK OFFLINE: Si no hay internet en Quito, lee directo de SQLite
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
