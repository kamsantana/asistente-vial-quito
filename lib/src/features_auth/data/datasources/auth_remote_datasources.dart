import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // Instancias oficiales de Firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> loginRemote(
    String email,
    String password,
  ) async {
    try {
      // 🚀 Petición real a Firebase Auth
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final User? user = userCredential.user;

      if (user != null) {
        // 🔄 TRANSFORMAR EN DINÁMICO: Buscamos la placa real guardada en Firestore usando el UID único
        String placaReal = "No asignada";
        try {
          final userDoc = await _firestore
              .collection('usuarios')
              .doc(user.uid)
              .get();
          if (userDoc.exists && userDoc.data() != null) {
            placaReal = userDoc.data()?['licensePlate'] ?? "No asignada";
          }
        } catch (e) {
          print(
            "⚠️ Alerta (No detiene el flujo): No se pudo leer la placa desde Firestore en el login: $e",
          );
        }

        // Devolvemos exactamente el formato de mapa que tu app ya espera recibir
        return {
          "id": user.uid,
          "name": user.displayName ?? "Conductor de Quito",
          "email": user.email,
          "licensePlate": placaReal,
        };
      } else {
        throw Exception("No se pudo obtener la información del usuario.");
      }
    } on FirebaseAuthException catch (e) {
      // Control de errores amigable para el usuario
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception(
          "Credenciales incorrectas. Verifica tu correo o contraseña.",
        );
      } else if (e.code == 'wrong-password') {
        throw Exception("Contraseña incorrecta.");
      } else if (e.code == 'invalid-email') {
        throw Exception("El formato del correo electrónico no es válido.");
      }
      throw Exception(e.message ?? "Error en la autenticación.");
    }
  }

  @override
  Future<Map<String, dynamic>> registerRemote({
    required String name,
    required String email,
    required String password,
    required String licensePlate,
  }) async {
    try {
      // 1. 🚀 Creamos el usuario en la nube de Firebase Auth
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final User? user = userCredential.user;

      if (user != null) {
        // 2. Guardamos el nombre del conductor dentro del perfil básico de Firebase
        await user.updateDisplayName(name);
        await user.reload(); // Refresca los datos locales del usuario

        // 3. 🔥 ENLACE CON FIRESTORE: Guardamos la placa vinculada al UID único con sus valores por defecto
        await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
              'uid': user.uid,
              'name': name,
              'email': email.trim(),
              'licensePlate': licensePlate
                  .trim()
                  .toUpperCase(), // Placa limpia en mayúsculas
              'tipo_licencia':
                  'E Profesional', // 🟢 Agregado para tu PerfilView
              'puntos': '30 / 30 Vigentes', // 🟢 Agregado para tu PerfilView
              'fecha_registro': FieldValue.serverTimestamp(),
              'rol': 'conductor',
            })
            .timeout(const Duration(seconds: 4));

        print(
          "🔥 Conductor registrado exitosamente en Auth y sus datos base guardados en Firestore.",
        );

        return {
          "id": user.uid,
          "name": name,
          "email": email,
          "licensePlate": licensePlate,
        };
      } else {
        throw Exception("Error al crear la cuenta del conductor.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
          "Este correo electrónico ya está registrado en el sistema.",
        );
      } else if (e.code == 'weak-password') {
        throw Exception(
          "La contraseña es muy débil. Intenta con al menos 6 caracteres.",
        );
      }
      throw Exception(e.message ?? "Error al registrar conductor.");
    } catch (e) {
      throw Exception(
        "Error al guardar los datos vehiculares del conductor: $e",
      );
    }
  }
}
