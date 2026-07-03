import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_notifier.dart';
import 'login_view.dart';

class PerfilView extends StatefulWidget {
  final String driverName;

  const PerfilView({super.key, required this.driverName});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  // Colores corporativos basados en tu HomeView
  static const Color primaryColor = Color(0xFF0F3077); // Azul profundo Quito
  static const Color accentColor = Color(0xFFE30613); // Rojo corporativo
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String? uid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: backgroundColor,
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

          final data = snapshot.data?.data();

          final String placaReal = data?['licensePlate'] ?? "Asignando...";
          final String tipoLicencia = data?['tipo_licencia'] ?? "E Profesional";
          final String puntosValidos = data?['puntos'] ?? "30 / 30 Vigentes";

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. ENCABEZADO CON DEGRADADO Y AVATAR
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
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: backgroundColor,
                          child: Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.driverName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Conductor AMT Activo",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. CUERPO E INFORMACIÓN DETALLADA
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Información Institucional",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tarjeta de Datos Reactiva
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
                              _buildPerfilItem(
                                Icons.badge_rounded,
                                "Entidad",
                                "Agencia Metropolitana de Tránsito",
                                Colors.black87,
                              ),
                              const Divider(height: 24),
                              _buildPerfilItem(
                                Icons.directions_car_rounded,
                                "Placa Vehicular",
                                placaReal,
                                Colors.black87,
                              ),
                              const Divider(height: 24),
                              _buildPerfilItem(
                                Icons.credit_card_rounded,
                                "Tipo de Licencia",
                                tipoLicencia,
                                Colors.black87,
                              ),
                              const Divider(height: 24),
                              _buildPerfilItem(
                                Icons.stars_rounded,
                                "Puntos de Control",
                                puntosValidos,
                                Colors.black87,
                              ),
                              const Divider(height: 24),
                              _buildPerfilItem(
                                Icons.gavel_rounded,
                                "Jurisdicción",
                                "Distrito Metropolitano de Quito",
                                Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón institucional interactivo
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.verified_user_rounded,
                            color: primaryColor,
                          ),
                          label: const Text(
                            "Ver Credencial Digital",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🚪 BOTÓN DE CERRAR SESIÓN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Provider.of<AuthNotifier>(
                              context,
                              listen: false,
                            ).logout(context);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "CERRAR SESIÓN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
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

  Widget _buildPerfilItem(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
