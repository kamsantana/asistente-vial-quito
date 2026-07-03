import 'dart:convert';
import 'package:dio/dio.dart';
// 🛠️ 1. IMPORTACIÓN OBLIGATORIA
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiParserDataSource {
  final Dio _dio = Dio();

  // 🟢 2. MODIFICADO: Lee la clave desde el archivo .env de forma segura
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  final String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<Map<String, dynamic>> cleanJsonWithGemini(
    Map<String, dynamic> denseJson,
  ) async {
    // 🔕 Volvemos a activar la validación por si acaso el archivo .env no se leyó bien
    if (_apiKey.isEmpty) {
      print(
        "⚠️ Alerta crítica: No se cargó la API Key desde el .env. Usando modo local alterno.",
      );
      return _getFallbackResponse(denseJson);
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
            // Se usa la variable dinámica sin el static const anterior
            "Authorization": "Bearer ${_apiKey.trim()}",
            "Content-Type": "application/json",
          },
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
      print(
        "🌐 Entorno Web: Retornando reporte simulado directo para evitar bloqueo en la UI.",
      );
      return _getFallbackResponse(denseJson);
    } catch (e) {
      print("❌ Error al conectar con la API de Groq: $e");
      return _getFallbackResponse(denseJson);
    }
  }

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
