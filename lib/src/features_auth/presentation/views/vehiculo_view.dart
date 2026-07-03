import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Importamos Firestore para la lectura real
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Importamos Auth para capturar el UID
import 'package:flutter/material.dart';

class VehiculoView extends StatefulWidget {
  final String driverPlate;

  const VehiculoView({super.key, required this.driverPlate});

  @override
  State<VehiculoView> createState() => _VehiculoViewState();
}

class _VehiculoViewState extends State<VehiculoView> {
  static const Color primaryColor = Color(0xFF0F3077); // Azul profundo Quito
  static const Color greenColor = Color(0xFF2E7D32); // Verde operativo
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String? uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: backgroundColor,
      // 🔥 Conexión reactiva directa al perfil del conductor en Firestore
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: uid != null
            ? _firestore.collection('usuarios').doc(uid).snapshots()
            : const Stream.empty(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // Extraemos de forma segura los datos del nodo del usuario
          final data = snapshot.data?.data();

          // Mapeo dinámico con respaldos (fallbacks) por si no existen aún en tu Firestore
          final String placaReal = data?['licensePlate'] ?? widget.driverPlate;
          final String modeloAuto =
              data?['vehicleModel'] ?? "Nissan Versa • 2023";
          final String chasis = data?['chasis'] ?? "1N4AL3AP1NC123456";
          final String colorOficial = data?['color'] ?? "Blanco / Azul";
          final String combustible = data?['combustible'] ?? "Gasolina";
          final String revisionTecnica = data?['rtvStatus'] ?? "Aprobada 2026";
          final String estadoCirculacion =
              data?['circulacionStatus'] ?? "Apto para Circulación";

          return SingleChildScrollView(
            child: Column(
              children: [
                // Encabezado con efecto de Placa de Ecuador
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, Color(0xFF1A459C)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 32,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_car_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Placa Amarilla Reflectiva
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9C4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black87, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          placaReal.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        modeloAuto,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado Técnico y Detalle
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: greenColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: greenColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Estado del Vehículo",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      estadoCirculacion,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Ficha Técnica Registrada",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildVehiculoItem(
                                Icons.confirmation_number_rounded,
                                "Chasis",
                                chasis,
                              ),
                              const Divider(height: 24),
                              _buildVehiculoItem(
                                Icons.opacity_rounded,
                                "Color oficial",
                                colorOficial,
                              ),
                              const Divider(height: 24),
                              _buildVehiculoItem(
                                Icons.local_gas_station_rounded,
                                "Combustible",
                                combustible,
                              ),
                              const Divider(height: 24),
                              _buildVehiculoItem(
                                Icons.fact_check_rounded,
                                "Revisión Técnica (RTV)",
                                revisionTecnica,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehiculoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
