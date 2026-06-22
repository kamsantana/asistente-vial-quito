import 'dart:convert';
import 'package:dio/dio.dart';

class AiParserDataSource {
  final Dio _dio = Dio();

  // 🔑 SEGURO: La API Key ahora se inyecta desde las variables de entorno
  // Ya no está hardcoded, evitando bloqueos o robos en GitHub.
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  final String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<Map<String, dynamic>> cleanJsonWithGemini(
    Map<String, dynamic> denseJson,
  ) async {
    // Validación preventiva por si olvidas pasar la bandera en la consola
    if (_apiKey.isEmpty) {
      print(
        "⚠️ Alerta: La variable 'GROQ_API_KEY' está vacía. Verifica tu config.json",
      );
    }

    final prompt =
        '''
    Eres un analizador de datos experto para la app Asistencia Vial Quito. 
    Analiza el siguiente JSON complejo, limpia la grasa técnica y optimízalo. 
    Devuelve ÚNICA Y ESTRICTAMENTE un objeto JSON válido estructurado con estas llaves exactas:
    - "id": (usa el id original o genera uno corto)
    - "titulo": (título corto del incidente o noticia)
    - "resumen_ia": (resumen ejecutivo limpio de máximo dos líneas)
    - "nivel_gravedad": (evalúa el peligro y pon solo: "BAJO", "MEDIO" o "ALTO")

    JSON denso a procesar:
    ${jsonEncode(denseJson)}
    ''';

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
          // 🛠️ Evita que la Web se quede colgada indefinidamente si el navegador bloquea la petición
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
        data: {
          "model": "llama-3.1-8b-instant",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          "response_format": {"type": "json_object"},
          "temperature": 0.1,
        },
      );

      if (response.statusCode == 200) {
        final rawContent =
            response.data['choices'][0]['message']['content'] as String;
        return jsonDecode(rawContent) as Map<String, dynamic>;
      } else {
        throw Exception(
          "Error en la respuesta de Groq: ${response.statusCode}",
        );
      }
    } on DioException catch (de) {
      print("❌ Error de red en Groq (Dio): ${de.response?.data ?? de.message}");

      // 🌐 Si estás en entorno Web y salta un error de red o CORS, devolvemos un fallback estructurado
      // para que la interfaz gráfica dibuje la tarjeta sin romperse.
      print(
        "🌐 Entorno Web: Retornando reporte simulado directo para evitar bloqueo en la UI.",
      );
      return _getFallbackResponse(denseJson);
    } catch (e) {
      print("❌ Error al conectar con la API de Groq: $e");
      return _getFallbackResponse(denseJson);
    }
  }

  // 🛠️ Función de respaldo que genera las llaves exactas que necesita tu UI si la red web falla
  Map<String, dynamic> _getFallbackResponse(Map<String, dynamic> denseJson) {
    final mockId = denseJson['id'] ?? denseJson['_id'] ?? 'ID-MOCK';
    final mockTitle =
        denseJson['title'] ?? denseJson['titulo'] ?? 'Novedad Vial AMT';
    final mockDesc =
        denseJson['description'] ??
        denseJson['descripcion'] ??
        'Cierre o control en la vía.';

    return {
      "id": mockId.toString(),
      "titulo": "$mockTitle (Local)",
      "resumen_ia":
          "IA Reporta: Novedad en gestión vial de Quito. $mockDesc Tome rutas alternas.",
      "nivel_gravedad": "MEDIO",
    };
  }
}
