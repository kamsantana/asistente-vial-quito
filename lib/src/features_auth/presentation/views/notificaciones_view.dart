import 'dart:async';
import 'package:flutter/material.dart';

// Mantenemos consistencia con los colores globales de tu app
const Color primaryColor = Color(0xFF0F3077); // Azul Quito
const Color accentColor = Color(0xFFE30613); // Rojo corporativo
const Color orangeColor = Color(0xFFEF6C00); // Naranja preventivo
const Color greenColor = Color(0xFF2E7D32); // Verde operativo
const Color backgroundColor = Color(0xFFF5F7FA);

class NotificacionesView extends StatefulWidget {
  const NotificacionesView({super.key});

  @override
  State<NotificacionesView> createState() => _NotificacionesViewState();
}

class _NotificacionesViewState extends State<NotificacionesView> {
  // 🔥 El controlador del flujo en tiempo real
  late StreamController<List<Map<String, dynamic>>> _alertsStreamController;

  // Lista en memoria que crecerá o se actualizará en tiempo real
  final List<Map<String, dynamic>> _listaAlertas = [];

  @override
  void initState() {
    super.initState();
    _alertsStreamController = StreamController<List<Map<String, dynamic>>>();
    _inicializarFlujoTiempoReal();
  }

  @override
  void dispose() {
    _alertsStreamController
        .close(); // 🛠️ Cerramos el stream para evitar fugas de memoria
    super.dispose();
  }

  /// 🌐 CONEXIÓN EN TIEMPO REAL
  /// Aquí simulo la llegada de reportes cada 4 segundos. En tu Clean Architecture,
  /// este método llamará al Stream de Firebase, WebSockets o polling de tu UseCase.
  void _inicializarFlujoTiempoReal() {
    // 1. Datos iniciales de arranque
    _listaAlertas.addAll([
      {
        "tipo": "CRÍTICO",
        "titulo": "Contraflujo Activo: Túnel Guayasamín",
        "descripcion":
            "Rige desde las 16:00 hasta las 19:30 en sentido Quito-Valles. Tome vías alternas por la Av. Simón Bolívar.",
        "tiempo": "Ahora mismo",
        "icono": Icons.swap_horizontal_circle_rounded,
        "color": accentColor,
      },
      {
        "tipo": "PREVENTIVO",
        "titulo": "Cierre Vial por Obra: Av. Mariana de Jesús",
        "descripcion":
            "Trabajos de repavimentación en sentido Este-Oeste entre Av. Amazonas y Av. de la Prensa.",
        "tiempo": "Hace 25 min",
        "icono": Icons.construction_rounded,
        "color": orangeColor,
      },
    ]);
    _alertsStreamController.add(_listaAlertas);

    // 2. Simulación de un evento nuevo llegando en vivo desde el servidor
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _listaAlertas.insert(0, {
          "tipo": "TRÁFICO",
          "titulo": "¡NUEVO! Congestión Alta: Av. Mariscal Sucre",
          "descripcion":
              "Tránsito lento a la altura de los túneles de San Juan en sentido Sur-Norte por percance vehicular leve.",
          "tiempo": "Hace 1 min",
          "icono": Icons.traffic_rounded,
          "color": orangeColor,
        });
        // Notificamos al StreamBuilder que hay nuevos datos en tiempo real
        _alertsStreamController.add(List.from(_listaAlertas));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _alertsStreamController.stream,
        builder: (context, snapshot) {
          // Mientras espera que conecte el flujo en tiempo real
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Si ocurre un error en la conexión de red
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar alertas en tiempo real"),
            );
          }

          final alertas = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ENCABEZADO DE SECCIÓN ---
                const Text(
                  "Alertas en el DMQ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Text(
                  "Estado vial y reportes de la Agencia Metropolitana de Tránsito",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // --- CONTADORES RÁPIDOS DINÁMICOS ---
                Row(
                  children: [
                    _buildContadorCard(
                      "${alertas.where((e) => e['tipo'] == 'CRÍTICO').length} Activa",
                      "Críticas",
                      accentColor,
                    ),
                    const SizedBox(width: 8),
                    _buildContadorCard(
                      "${alertas.length} Reportes",
                      "Viales",
                      orangeColor,
                    ),
                    const SizedBox(width: 8),
                    _buildContadorCard("Normal", "Radares", greenColor),
                  ],
                ),
                const SizedBox(height: 20),

                // --- LISTA EN TIEMPO REAL ---
                alertas.isEmpty
                    ? const Center(
                        child: Text("No hay alertas viales por el momento"),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alertas.length,
                        itemBuilder: (context, index) {
                          final alerta = alertas[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: alerta['color'],
                                      width: 5,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: alerta['color']
                                          .withOpacity(0.1),
                                      radius: 22,
                                      child: Icon(
                                        alerta['icono'],
                                        color: alerta['color'],
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: alerta['color']
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  alerta['tipo'],
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: alerta['color'],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                alerta['tiempo'],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            alerta['titulo'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            alerta['descripcion'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContadorCard(String valor, String etiqueta, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
