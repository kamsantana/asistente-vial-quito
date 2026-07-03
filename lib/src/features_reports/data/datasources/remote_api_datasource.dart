import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 IMPORTACIÓN DE FIREBASE
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 🛠️ Para detectar la Web

class RemoteApiDataSource {
  final Dio _dio;

  // 🔥 Instancia del cliente de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RemoteApiDataSource(this._dio);

  /// Cambiamos la firma para que devuelva una lista de mapas (múltiples reportes)
  Future<List<Map<String, dynamic>>> fetchDenseTrafficReportsList() async {
    try {
      print("📡 Consultando incidentes reales desde Cloud Firestore...");

      // 1. Obtenemos los documentos de la colección 'reportes' ordenados por los más recientes
      final querySnapshot = await _firestore
          .collection('reportes')
          .orderBy('fecha_sincronizacion', descending: true)
          .get()
          .timeout(const Duration(seconds: 5));

      // 2. Si la base de datos está vacía, insertamos un respaldo o retornamos vacío
      if (querySnapshot.docs.isEmpty) {
        print("ℹ️ No hay reportes en la nube. Retornando lista vacía.");
        return [];
      }

      // 3. Mapeamos cada documento de Firestore al formato que tu ReportEntity/Model procesa
      List<Map<String, dynamic>> listaFormateada = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        listaFormateada.add({
          "id": doc.id,
          "titulo": data['titulo'] ?? 'Incidente Vial',
          "nivel_gravedad": data['nivel_gravedad'] ?? 'MEDIA',
          "resumen_ia":
              data['resumen_ia'] ??
              (data['incidente_vial'] ?? 'Sin descripción disponible.'),
          "ubicacion": data['ubicacion'] ?? 'Quito, Ecuador',
          "timestamp": data['fecha_sincronizacion'] != null
              ? (data['fecha_sincronizacion'] as Timestamp)
                    .millisecondsSinceEpoch
              : DateTime.now().millisecondsSinceEpoch,
        });
      }

      return listaFormateada;
    } catch (e) {
      print("❌ Error al leer Firestore: $e");
      // Si la red falla por completo en Web, devolvemos al menos un reporte local de contingencia
      return [
        {
          "id": "fallback_1",
          "titulo": "Colisión en Sector Santo Domingo",
          "nivel_gravedad": "ALTA",
          "resumen_ia":
              "Choque entre un Trolebús y dos autos causa obstrucción total en la Av. Maldonado. (Modo Contingencia Local)",
          "ubicacion": "Av. Maldonado y Flores",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        },
      ];
    }
  }

  /// Mantenemos el método viejo vacío por compatibilidad si lo compila algún Repositorio temporalmente
  Future<Map<String, dynamic>> fetchDenseTrafficReport() async {
    final list = await fetchDenseTrafficReportsList();
    return list.isNotEmpty ? list.first : {};
  }
}
