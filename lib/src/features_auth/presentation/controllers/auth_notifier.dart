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

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDriver = await loginUseCase.execute(email, password);
      _status = AuthStatus.authenticated;
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

  void logout() {
    _currentDriver = null;
    _status = AuthStatus.initial;
    notifyListeners();
  }
}
