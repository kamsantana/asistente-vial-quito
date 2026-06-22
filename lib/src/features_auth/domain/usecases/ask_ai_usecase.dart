import 'dart:convert';
import 'package:http/http.dart' as http;

class AskAiUseCase {
  // 🔑 SEGURO: Eliminamos la clave hardcoded del defaultValue.
  // Ahora lee directamente la variable desde el config.json compilado.
  final String _apiKey = const String.fromEnvironment('GROQ_API_KEY');

  Future<String> execute(String prompt) async {
    // Validación preventiva por si olvidas pasar el comando en consola
    if (_apiKey.isEmpty) {
      print(
        "⚠️ Alerta: La variable 'GROQ_API_KEY' está vacía en AskAiUseCase. Revisa tu config.json",
      );
      return "Error del sistema: Falta la configuración de la clave de IA.";
    }

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

      // 🛠️ DIAGNÓSTICO COMPLETO DE ERRORES
      if (response.statusCode != 200) {
        print("❌ ¡GROQ DEVOLVIÓ ERROR Code ${response.statusCode}!");
        print("👉 DETALLE EXACTO: ${response.body}");

        final decodedBody = jsonDecode(response.body);
        if (decodedBody['error'] != null) {
          return "Error de configuración de IA: ${decodedBody['error']['message']}";
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse = data['choices'][0]['message']['content'];
        return textResponse;
      } else {
        return "No se pudo obtener respuesta del asistente (Código ${response.statusCode})";
      }
    } catch (e) {
      print("❌ Fallo crítico en el bloque try-catch: $e");
      return "Error al conectar con el asistente en tiempo real: ${e.toString()}";
    }
  }
}
