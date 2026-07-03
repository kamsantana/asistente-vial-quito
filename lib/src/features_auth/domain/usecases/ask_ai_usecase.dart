import 'dart:convert';
import 'package:http/http.dart' as http;
// 🛠️ 1. IMPORTACIÓN OBLIGATORIA
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AskAiUseCase {
  // 🟢 2. MODIFICADO: Lee la clave desde el archivo .env de forma segura sin static const
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> execute(String prompt) async {
    // 🛠️ 3. VALIDACIÓN PREVENTIVA: Si la clave está vacía, responde con un JSON local controlado
    if (_apiKey.isEmpty) {
      print(
        "⚠️ Alerta crítica: No se cargó la API Key desde el .env en AskAiUseCase.",
      );
      return jsonEncode({
        "text":
            "El servicio de asistencia vial no se encuentra disponible temporalmente por falta de credenciales.",
        "lat": null,
        "lng": null,
      });
    }

    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final body = jsonEncode({
        "model": "llama-3.1-8b-instant",
        "response_format": {"type": "json_object"},
        "messages": [
          {
            "role": "system",
            "content":
                "Eres el Agente Virtual de la Agencia Metropolitana de Tránsito (AMT) de Quito. "
                "Responde de forma amable, corta y concisa las dudas sobre movilidad, pico y placa y rutas. "
                "\n\nTABLA DE COORDENADAS OFICIALES (Úsalas estrictamente si te preguntan por estos lugares):\n"
                "- Basílica del Voto Nacional: lat = -0.214714, lng = -78.507137\n"
                "- Plaza Grande / Plaza de la Independencia: lat = -0.220138, lng = -78.512217\n"
                "- El Panecillo: lat = -0.228333, lng = -78.518611\n"
                "- Parque La Carolina: lat = -0.182285, lng = -78.484252\n"
                "- Parque El Ejido: lat = -0.213271, lng = -78.496055\n"
                "- Terminal Terrestre Quitumbe: lat = -0.291350, lng = -78.558364\n"
                "- Terminal Terrestre Carcelén: lat = -0.095454, lng = -78.472851\n"
                "- CCI (Centro Comercial Iñaquito): lat = -0.179833, lng = -78.484556\n"
                "- Universidad Central del Ecuador: lat = -0.200388, lng = -78.502931\n\n"
                "DEBES responder ÚNICA Y ESTRICTAMENTE en formato JSON con la siguiente estructura exacta:\n"
                "{\n"
                "  \"text\": \"(Aquí pones tu respuesta de texto de ayuda habitual. Si es sobre la Basílica, aclara que NO está en la Plaza Grande, está en las calles Carchi y Venezuela)\",\n"
                "  \"lat\": (Pon la latitud exacta extraída de la tabla anterior en formato número flotante si aplica, sino pon null),\n"
                "  \"lng\": (Pon la longitud exacta extraída de la tabla anterior en formato número flotante si aplica, sino pon null)\n"
                "}",
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.1,
      });

      print("🌐 Enviando petición estructurada a Groq...");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${_apiKey.trim()}',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        print("❌ ¡GROQ DEVOLVIÓ ERROR Code ${response.statusCode}!");
        print("👉 DETALLE EXACTO: ${response.body}");
        return jsonEncode({
          "text": "Error al obtener respuesta del asistente.",
          "lat": null,
          "lng": null,
        });
      }

      final data = jsonDecode(response.body);
      final String rawContent = data['choices'][0]['message']['content'];

      return rawContent;
    } catch (e) {
      print("❌ Fallo crítico en el bloque try-catch: $e");
      return jsonEncode({
        "text": "Error al conectar con el asistente en tiempo real.",
        "lat": null,
        "lng": null,
      });
    }
  }
}
