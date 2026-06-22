import 'package:flutter/material.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/login_driver_usecase.dart';
import '../../domain/usecases/register_driver_usecase.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthNotifier extends ChangeNotifier {
  final LoginDriverUseCase loginUseCase;
  final RegisterDriverUseCase registerUseCase;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  Driver? _currentDriver;

  AuthNotifier({required this.loginUseCase, required this.registerUseCase});

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Driver? get currentDriver => _currentDriver;

  // Colores de la app para los SnackBars
  static const Color primaryColor = Color(0xFF0F3077); // Azul Quito
  static const Color greenColor = Color(0xFF2E7D32); // Verde operativo

  /// 🔐 INICIO DE SESIÓN CON ALERTA EXITOSA
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDriver = await loginUseCase.execute(email, password);
      _status = AuthStatus.authenticated;

      // 🟢 Si todo sale bien, disparamos el SnackBar de éxito antes del redireccionamiento
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                // 🛠️ CORRECCIÓN: Envolver en Expanded para evitar desbordes con nombres largos
                Expanded(
                  child: Text(
                    "¡Iniciado sesión con éxito! Bienvenido, ${_currentDriver?.name ?? ''}",
                  ),
                ),
              ],
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDriver = await registerUseCase.execute(
        name: name,
        email: email,
        password: password,
        licensePlate: licensePlate,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    }
    notifyListeners();
  }

  /// 🚪 CIERRE DE SESIÓN CON ALERTA
  void logout(BuildContext context) {
    _currentDriver = null;
    _status = AuthStatus.initial;

    // 🔵 Disparamos el SnackBar informativo de sesión cerrada
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white),
              const SizedBox(width: 10),
              // 🛠️ CORRECCIÓN: También protegido con Expanded por si acaso
              Expanded(child: Text("Cerrado sesión con éxito")),
            ],
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    notifyListeners();
  }
}
