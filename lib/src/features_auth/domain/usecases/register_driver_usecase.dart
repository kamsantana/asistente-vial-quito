import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

class RegisterDriverUseCase {
  final AuthRepository repository;

  RegisterDriverUseCase(this.repository);

  Future<Driver> execute({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  }) async {
    // Validación académica de la placa de Quito (Pichincha empieza con P)
    final uppercasePlate = licensePlate.toUpperCase().trim();
    if (!uppercasePlate.startsWith('P')) {
      throw Exception(
        "La placa debe pertenecer a la provincia de Pichincha (Debe iniciar con 'P').",
      );
    }

    return await repository.register(
      name: name,
      email: email,
      password: password,
      licensePlate: uppercasePlate,
    );
  }
}
