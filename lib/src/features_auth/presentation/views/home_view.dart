import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_notifier.dart';
import '../../domain/usecases/ask_ai_usecase.dart';
import 'login_view.dart';
import 'package:asitente_vial/src/features_reports/presentation/views/report_view.dart';

// ✅ PASO 1: COLORES GLOBALES
const Color primaryColor = Color(0xFF0F3077); // Azul profundo Quito
const Color accentColor = Color(0xFFE30613); // Rojo corporativo
const Color greenColor = Color(0xFF2E7D32); // Verde operativo
const Color backgroundColor = Color(0xFFF5F7FA);

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // --- VARIABLES DE ESTADO ---
  int _actualIndex = 0; // Controla el menú inferior
  String _selectedTab = "MI VEHÍCULO"; // Controla las pestañas superiores

  // --- CONTROLADORES PARA EL MOTOR DE IA ---
  final TextEditingController _aiController = TextEditingController();
  final AskAiUseCase _askAiUseCase = AskAiUseCase();
  bool _isLoadingAi = false;

  @override
  void dispose() {
    _aiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos de forma reactiva los datos del conductor desde tu AuthNotifier
    final authNotifier = context.watch<AuthNotifier>();
    final driverName = authNotifier.currentDriver?.name ?? "Conductor";
    final driverPlate = authNotifier.currentDriver?.licensePlate ?? "S/P";

    return Scaffold(
      backgroundColor: backgroundColor,

      // 1. BARRA SUPERIOR (AppBar)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $driverName",
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Text(
              "Panel de Control Metropolitana",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // 🚀 BOTÓN TEMPORAL DE PRUEBA PARA NAVEGAR A LOS REPORTES IA
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 26),
            tooltip: 'Probar Reportes Groq',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportView()),
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: accentColor),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              context.read<AuthNotifier>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 2. CUERPO DE LA APLICACIÓN
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- PESTAÑAS DE NAVEGACIÓN RÁPIDA ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem("MI VEHÍCULO"),
                  _buildTabItem("TURNOS"),
                  _buildTabItem("ALERTAS"),
                  _buildTabItem("PERFIL"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- RENDERIZADO DINÁMICO SEGÚN LA PESTAÑA ACTIVA ---
            if (_selectedTab == "MI VEHÍCULO") ...[
              // Tarjeta 1: Estado del auto
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Estado Vehicular",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(Icons.check_circle, color: greenColor, size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "VEHÍCULO OPERATIVO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataRow("Placa:", driverPlate),
                      _buildDataRow("Año/Modelo:", "2023 / Nissan Versa"),
                      _buildDataRow("Propietario:", driverName),
                      _buildDataRow("Último Mantenimiento:", "15 Oct 2025"),
                      const Padding(
                        padding: EdgeInsets.only(left: 100, top: 2),
                        child: Text(
                          "(Próximo: 15 Dic 2026 - Aceite)",
                          style: TextStyle(fontSize: 11, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta 2: Turnos asignados
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Turnos de Hoy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "• Turno A: 08:00 - 14:00",
                                style: TextStyle(color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "• Turno B: 09:00 - 14:00",
                                style: TextStyle(color: Colors.black87),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "• Turno C: 12:00 - 18:00",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                          // 🛠️ CORRECCIÓN: Ahora el botón navega directamente a la pantalla de reportes
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportView(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Ver Mapa\nDetallado",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tarjeta 3: Alertas del sistema
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Alertas Recientes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAlertTile(
                        Icons.traffic_rounded,
                        "Traffic: Av. Amazonas congestionado",
                        "10m ago",
                      ),
                      const Divider(height: 16),
                      _buildAlertTile(
                        Icons.health_and_safety_rounded,
                        "Safety: Recuerda usar el cinturón",
                        "1h ago",
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Manejo dinámico para las otras pestañas
              if (_selectedTab == "TURNOS")
                _buildModulosPlaceholder(
                  "Gestión de Cronogramas",
                  "No registras más turnos complementarios asignados para esta semana.",
                ),
              if (_selectedTab == "ALERTAS")
                _buildModulosPlaceholder(
                  "Reportes Viales AMT",
                  "Historial consolidado de contraflujos activos, obras civiles y fotomultas en Quito.",
                ),
              if (_selectedTab == "PERFIL")
                _buildModulosPlaceholder(
                  "Datos Institucionales",
                  "Licencia Tipo: E Profesional\nPuntos de Control: 30/30 Vigentes\nEntidad: Agencia Metropolitana de Tránsito.",
                ),
            ],

            const SizedBox(height: 16),

            // --- SECCIÓN DE INTELIGENCIA ARTIFICIAL ---
            _buildCardAsistenteIA(),
          ],
        ),
      ),

      // 3. BARRA DE NAVEGACIÓN INFERIOR DINÁMICA
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _actualIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _actualIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 28),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_rounded, size: 28),
            label: 'Vehículo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded, size: 28),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded, size: 28),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 28),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTabItem(String text) {
    final bool isActive = _selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCardAsistenteIA() {
    return Card(
      color: Colors.blue[50],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology_rounded, color: primaryColor, size: 24),
                SizedBox(width: 8),
                Text(
                  "Asistente de Tránsito IA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Hazle preguntas operativas sobre normativas, rutas o incidentes.",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _aiController,
              decoration: InputDecoration(
                hintText: 'Ej: ¿A qué hora rige el Contraflujo en el Túnel?',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _isLoadingAi
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: primaryColor,
                        ),
                        onPressed: _consultarConGemini,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _consultarConGemini() async {
    final consulta = _aiController.text.trim();
    if (consulta.isEmpty) return;

    setState(() {
      _isLoadingAi = true;
    });

    final respuesta = await _askAiUseCase.execute(consulta);

    setState(() {
      _isLoadingAi = false;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.android_rounded, color: Colors.blue[800]),
            const SizedBox(width: 8),
            const Text(
              "Agente Virtual AMT",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            respuesta,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _aiController.clear();
            },
            child: const Text(
              "Entendido",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulosPlaceholder(String titulo, String cuerpo) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cuerpo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(IconData icon, String title, String time) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.red[50],
          child: Icon(icon, color: Colors.redAccent, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
