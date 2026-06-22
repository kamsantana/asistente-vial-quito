import 'dart:async';
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
  // 🔥 El controlador del flujo en tiempo real para los datos del conductor
  late StreamController<Map<String, dynamic>> _profileStreamController;

  // Colores corporativos basados en tu HomeView
  static const Color primaryColor = Color(0xFF0F3077); // Azul profundo Quito
  static const Color accentColor = Color(0xFFE30613); // Rojo corporativo
  static const Color backgroundColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _profileStreamController = StreamController<Map<String, dynamic>>();
    _conectarPerfilTiempoReal();
  }

  @override
  void dispose() {
    _profileStreamController
        .close(); // 🛠️ Liberamos memoria al destruir el widget
    super.dispose();
  }

  /// 🌐 CONEXIÓN DE PERFIL EN TIEMPO REAL
  void _conectarPerfilTiempoReal() {
    // 1. Datos del estado actual del conductor
    final datosIniciales = {
      "tipo_licencia": "E Profesional",
      "puntos": "30 / 30 Vigentes",
      "puntos_color": Colors.black87,
      "estado_credencial": "Conductor AMT Activo",
    };
    _profileStreamController.add(datosIniciales);

    // 2. Simulación: Cambio en tiempo real
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        _profileStreamController.add({
          "tipo_licencia": "E Profesional",
          "puntos": "28 / 30 (Actualizado en vivo)",
          "puntos_color": accentColor,
          "estado_credencial": "Revisión de Puntos",
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _profileStreamController.stream,
        builder: (context, snapshot) {
          // Pantalla de carga mientras se sincroniza el perfil
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          final datos = snapshot.data ?? {};

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
                        child: Text(
                          datos['estado_credencial'] ?? "Cargando...",
                          style: const TextStyle(
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
                                Icons.credit_card_rounded,
                                "Tipo de Licencia",
                                datos['tipo_licencia'] ?? "---",
                                Colors.black87,
                              ),
                              const Divider(height: 24),
                              _buildPerfilItem(
                                Icons.stars_rounded,
                                "Puntos de Control",
                                datos['puntos'] ?? "---",
                                datos['puntos_color'] ?? Colors.black87,
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
                          onPressed: () {
                            // Acción para refrescar o ver detalles extendidos
                          },
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

                      // 🚪 BOTÓN DE CERRAR SESIÓN MODERNO
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 1. Llamamos al logout pasándole el context para activar el SnackBar
                            Provider.of<AuthNotifier>(
                              context,
                              listen: false,
                            ).logout(context);

                            // 2. Navegamos al login limpiando el stack de pantallas anteriores
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
                            backgroundColor:
                                accentColor, // Color Rojo Corporativo
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
