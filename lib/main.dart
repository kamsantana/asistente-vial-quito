import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🛠️ IMPORTACIÓN CLAVE: Para usar kIsWeb
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// ==========================================
// 📁 IMPORTACIONES: FEATURE AUTH
// ==========================================
import 'src/features_auth/data/datasources/auth_remote_datasources.dart';
import 'src/features_auth/data/repositories/auth_repository_impl.dart';
import 'src/features_auth/domain/usecases/login_driver_usecase.dart';
import 'src/features_auth/domain/usecases/register_driver_usecase.dart';
import 'src/features_auth/presentation/controllers/auth_notifier.dart';
import 'src/features_auth/presentation/views/login_view.dart';

// ==========================================
// 📁 IMPORTACIONES: FEATURE REPORTS
// ==========================================
import 'src/features_reports/data/datasources/ai_parser_datasource.dart';
import 'src/features_reports/data/datasources/local_sqlite_datasource.dart';
import 'src/features_reports/data/datasources/remote_api_datasource.dart';
import 'src/features_reports/data/repositories/report_repository_impl.dart';
import 'src/features_reports/domain/usecases/get_smart_reports_usecase.dart';
import 'src/features_reports/presentation/controllers/report_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛠️ CORRECCIÓN: Si es Web, evitamos usar 'Platform' por completo
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  // -------------------------------------------------------------
  // 1. Inicialización de dependencias - FEATURE AUTH
  // -------------------------------------------------------------
  final authRemoteDataSource = AuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );
  final loginUseCase = LoginDriverUseCase(authRepository);
  final registerUseCase = RegisterDriverUseCase(authRepository);

  // -------------------------------------------------------------
  // 2. Inicialización de dependencias - FEATURE REPORTS
  // -------------------------------------------------------------
  final dio = Dio();
  final reportRemoteDS = RemoteApiDataSource(dio);
  final reportAiDS = AiParserDataSource();
  final reportLocalDS = LocalSqliteDataSource();

  final reportRepository = ReportRepositoryImpl(
    remoteDataSource: reportRemoteDS,
    aiDataSource: reportAiDS,
    localDataSource: reportLocalDS,
  );

  final getSmartReportsUseCase = GetSmartReportsUseCase(reportRepository);

  // -------------------------------------------------------------
  // 3. Arranque de la App
  // -------------------------------------------------------------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportNotifier(getSmartReportsUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F3077);

    return MaterialApp(
      title: 'Control Vehicular - Quito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const LoginView(),
    );
  }
}
