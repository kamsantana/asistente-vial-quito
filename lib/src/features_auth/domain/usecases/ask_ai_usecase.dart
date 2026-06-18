import 'dart:convert';
import 'package:http/http.dart' as http;

class AskAiUseCase {
  // 🔑 Tu API Key activa de Groq
  final String _apiKey =
      "gsk_" + "7GHRbWKOAJS4xpCzgKIIWGdyb3FYlvm2wUA5uZjzi2rFJ0J2YhH0";

  Future<String> execute(String prompt) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final body = jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {
            "role": "system",
            "content":
                "Eres el Agente Virtual de la Agencia Metropolitana de Tránsito (AMT) de Quito. "
                "Responde de forma amable, corta y concisa las dudas sobre movilidad, pico y placa, "
                "contraflujos y control vehicular en el Distrito Metropolitano.",
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.7,
      });

      print("🌐 Enviando petición a Groq...");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // 🛠️ CAPTURA DE DIAGNÓSTICO EN CONSOLA
      if (response.statusCode == 400) {
        print("❌ ¡GROQ DEVOLVIÓ ERROR 400!");
        print("👉 DETALLE EXACTO DEL ERROR: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse = data['choices'][0]['message']['content'];
        return textResponse;
      } else {
        return "Error del servidor alternativo (Código ${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      print("❌ Fallo crítico en el bloque try-catch: $e");
      return "Error al conectar con el asistente en tiempo real: ${e.toString()}";
    }
  }
}
