import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapaDinamicoWidget extends StatelessWidget {
  final double lat;
  final double lng;

  const MapaDinamicoWidget({super.key, required this.lat, required this.lng});

  // Función interna para abrir Google Maps en una pestaña nueva
  Future<void> _abrirGoogleMaps() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Abre con éxito
    } else {
      throw 'No se pudo abrir el mapa: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
      ),
      child: InkWell(
        onTap:
            _abrirGoogleMaps, // Al hacer clic en cualquier parte de la tarjeta, abre el mapa
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, color: Colors.blue, size: 50),
            const SizedBox(height: 12),
            const Text(
              'Ver Ubicación en Google Maps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coordenadas: $lat, $lng',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
