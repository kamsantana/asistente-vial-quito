import 'dart:convert';
// Nota: Recuerda agregar la dependencia 'http' en tu pubspec.yaml si vas a usar peticiones reales
// import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> loginRemote(String email, String password);
  Future<Map<String, dynamic>> registerRemote({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> loginRemote(
    String email,
    String password,
  ) async {
    // Simulamos la respuesta JSON que enviaría tu API de Node.js/Python
    await Future.delayed(const Duration(seconds: 1)); // Simula latencia de red

    if (email == "javier@quito.com" && password == "123456") {
      return {
        "id": "usr_9921",
        "name": "Javier Gómez",
        "email": email,
        "licensePlate": "PBC-1234",
      };
    } else {
      throw Exception(
        "Credenciales incorrectas. Verifica tu correo o contraseña.",
      );
    }
  }

  @override
  Future<Map<String, dynamic>> registerRemote({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simula un registro exitoso devolviendo el mapa del nuevo usuario
    return {
      "id": "usr_${DateTime.now().millisecondsSinceEpoch}",
      "name": name,
      "email": email,
      "licensePlate": licensePlate,
    };
  }
}
