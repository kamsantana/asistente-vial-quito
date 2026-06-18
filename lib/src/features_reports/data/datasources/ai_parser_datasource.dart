import 'dart:convert';
import 'package:dio/dio.dart';

class AiParserDataSource {
  final Dio _dio = Dio();

  // 🔑 Configura aquí tus credenciales de Groq
  final String _apiKey =
      "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";
  final String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<Map<String, dynamic>> cleanJsonWithGemini(
    Map<String, dynamic> denseJson,
  ) async {
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
        ),
        data: {
          // 🚀 CORRECCIÓN: Actualizado al modelo rápido y vigente en la API de Groq
          "model": "llama-3.1-8b-instant",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          // Forzamos a Groq a responder estrictamente en formato JSON
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
      // Captura detallada por si el navegador bloquea la petición
      print("❌ Error de red en Groq (Dio): ${de.response?.data ?? de.message}");
      throw Exception("Fallo en Groq: ${de.response?.data ?? de.message}");
    } catch (e) {
      throw Exception("Error al conectar con la API de Groq: $e");
    }
  }
}
