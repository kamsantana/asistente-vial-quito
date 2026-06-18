import '../entities/driver.dart';

abstract class AuthRepository {
  // Define qué datos se necesitan para iniciar sesión
  Future<Driver> login(String email, String password);

  // Define qué datos se necesitan para registrar un conductor
  Future<Driver> register({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  });
}
