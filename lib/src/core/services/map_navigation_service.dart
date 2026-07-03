import 'package:url_launcher/url_launcher.dart';

class MapNavigationService {
  /// Abre Google Maps con una ruta hacia el destino indicado en Quito.
  static Future<void> openRouteInMaps(String destino) async {
    final encodedDestino = Uri.encodeComponent(destino);

    // 🌐 URL de búsqueda universal compatible con Web, Android e iOS
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedDestino";
    final Uri url = Uri.parse(googleMapsUrl);

    try {
      print("🌐 Redirigiendo a Google Maps para: $destino");
      await launchUrl(
        url,
        mode: LaunchMode
            .externalApplication, // Asegura que abra en una pestaña nueva en Chrome
      );
    } catch (e) {
      print("❌ Error al intentar abrir el mapa: $e");
    }
  }
}
