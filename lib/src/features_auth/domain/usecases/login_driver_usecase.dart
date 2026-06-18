import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

class LoginDriverUseCase {
  final AuthRepository repository;

  LoginDriverUseCase(this.repository);

  Future<Driver> execute(String email, String password) async {
    // Aquí puedes añadir validaciones globales antes de enviar los datos al repositorio
    if (email.isEmpty || password.isEmpty) {
      throw Exception("El correo y la contraseña no pueden estar vacíos.");
    }
    return await repository.login(email, password);
  }
}
