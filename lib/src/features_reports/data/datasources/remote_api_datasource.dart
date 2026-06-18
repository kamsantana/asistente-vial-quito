import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 🛠️ IMPORTACIÓN CLAVE: Para detectar la Web

class RemoteApiDataSource {
  final Dio _dio;
  RemoteApiDataSource(this._dio);

  Future<Map<String, dynamic>> fetchDenseTrafficReport() async {
    try {
      // ⏱️ Simulamos un retraso de red de 1 segundo para hacerlo realista
      await Future.delayed(const Duration(seconds: 1));

      // 🛠️ PARCHE WEB: Si estás en Chrome, evitamos que rompa el flujo más adelante
      if (kIsWeb) {
        print(
          "🌐 Entorno Web detectado: Retornando reporte simulado directo para la UI.",
        );
        return {
          "status_code": "OK_200",
          "timestamp": 1718670000,
          "metadata": {
            "source": "Agencia Metropolitana de Tránsito Quito",
            "operator_id": "AMT-405",
            "zone": "Pichincha/Quito/Centro Histórico",
          },
          "payload": {
            "incidente_vial":
                "Colisión múltiple entre un autobús articulado del Trolebús y dos vehículos particulares.",
            "ubicación_exacta":
                "Av. Maldonado y Flores, sector Santo Domingo, sentido sur-norte.",
            "afectacion_carriles":
                "Obstrucción total de los dos carriles del sistema integrado.",
            "personal_en_escena": ["AMT Unidad 12", "Bomberos Quito"],
            "detalles_tecnicos_adicionales":
                "Derrame de combustible sobre calzada húmeda. Tráfico pesado.",
          },
          // 💡 Añadimos estos campos extra simulando que la IA ya lo procesó
          // para saltarnos el error de Groq en la Web
          "id": "1",
          "titulo": "Colisión en Sector Santo Domingo",
          "resumen_ia":
              "Choque entre un Trolebús y dos autos causa obstrucción total de carriles exclusivos en la Av. Maldonado. Se reporta derrame de combustible y demoras de 45 minutos.",
          "nivel_gravedad": "ALTA",
        };
      }

      // 📝 Código original para Android / iOS / Desktop (pasa limpio hacia Groq)
      return {
        "status_code": "OK_200",
        "timestamp": 1718670000,
        "metadata": {
          "source": "Agencia Metropolitana de Tránsito Quito",
          "operator_id": "AMT-405",
          "zone": "Pichincha/Quito/Centro Histórico",
        },
        "payload": {
          "incidente_vial":
              "Colisión múltiple entre un autobús articulado del Trolebús y dos vehículos particulares tipo sedan de color negro y gris.",
          "ubicación_exacta":
              "Av. Maldonado y Flores, sector Santo Domingo, sentido sur-norte.",
          "afectacion_carriles":
              "Obstrucción total de los dos carriles del sistema integrado y un carril convencional.",
          "personal_en_escena": [
            "AMT Unidad 12",
            "Bomberos Quito Camión de Rescate",
            "Cruz Roja Ambulancia 3",
          ],
          "detalles_tecnicos_adicionales":
              "Derrame de combustible tipo diésel sobre la calzada húmeda por precipitaciones. Tráfico pesado con tiempos de espera de aproximadamente 45 minutos. Desvíos activos por la Av. Mariscal Sucre.",
        },
      };
    } catch (e) {
      throw Exception("Error al obtener datos crudos de la API externa: $e");
    }
  }
}
