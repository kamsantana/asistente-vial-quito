import '../../domain/entities/driver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Driver> login(String email, String password) async {
    try {
      final jsonMap = await remoteDataSource.loginRemote(email, password);
      // Mapeamos el JSON que viene del servidor hacia nuestra Entidad de Dominio
      return Driver(
        id: jsonMap['id'],
        name: jsonMap['name'],
        email: jsonMap['email'],
        licensePlate: jsonMap['licensePlate'],
      );
    } catch (e) {
      rethrow; // Lanza el error para que lo capture la interfaz de usuario
    }
  }

  @override
  Future<Driver> register({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  }) async {
    try {
      final jsonMap = await remoteDataSource.registerRemote(
        name: name,
        email: email,
        password: password,
        licensePlate: licensePlate,
      );
      return Driver(
        id: jsonMap['id'],
        name: jsonMap['name'],
        email: jsonMap['email'],
        licensePlate: jsonMap['licensePlate'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
