import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearReporteView extends StatefulWidget {
  const CrearReporteView({super.key});

  @override
  State<CrearReporteView> createState() => _CrearReporteViewState();
}

class _CrearReporteViewState extends State<CrearReporteView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto que el usuario escriba
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();

  // Opciones seleccionadas por defecto para los desplegables
  String _tipoIncidente = 'Choque / Colisión';
  String _gravedad = 'MEDIA';
  bool _subiendo = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _enviarReporte() async {
    // Si falta llenar algún campo obligatorio, frena el envío
    if (!_formKey.currentState!.validate()) return;

    setState(() => _subiendo = true);

    try {
      // 🔥 Guardamos el reporte real directo en tu colección de Firestore
      await FirebaseFirestore.instance.collection('reportes').add({
        'titulo': _tipoIncidente,
        'incidente_vial': _descripcionController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'resumen_ia': 'Reporte manual ingresado por el conductor en escena.',
        'nivel_gravedad': _gravedad,
        'fecha_sincronizacion': FieldValue.serverTimestamp(),
        'plataforma': 'Web Formulario',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 ¡Reporte vial enviado a la nube con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        // Cierra el formulario y regresa al panel principal
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al subir reporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Incidente Vial'),
        backgroundColor: const Color(0xFF0F1E36), // Color oscuro corporativo
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          // Limitamos el ancho máximo para que en pantallas de PC no se estire demasiado
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Detalles del Siniestro',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1E36),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🚗 Dropdown: Tipo de Incidente
                    DropdownButtonFormField<String>(
                      value: _tipoIncidente,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Incidente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Choque / Colisión',
                          child: Text('Choque / Colisión'),
                        ),
                        DropdownMenuItem(
                          value: 'Avería Mecánica',
                          child: Text('Avería Mecánica'),
                        ),
                        DropdownMenuItem(
                          value: 'Tráfico Denso / Bloqueo',
                          child: Text('Tráfico Denso / Bloqueo'),
                        ),
                        DropdownMenuItem(
                          value: 'Objeto en la Vía',
                          child: Text('Objeto en la Vía'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _tipoIncidente = value!),
                    ),
                    const SizedBox(height: 16),

                    // 🛑 Dropdown: Gravedad del Asunto
                    DropdownButtonFormField<String>(
                      value: _gravedad,
                      decoration: const InputDecoration(
                        labelText: 'Nivel de Gravedad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bar_chart),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BAJA', child: Text('BAJA')),
                        DropdownMenuItem(value: 'MEDIA', child: Text('MEDIA')),
                        DropdownMenuItem(value: 'ALTA', child: Text('ALTA')),
                      ],
                      onChanged: (value) => setState(() => _gravedad = value!),
                    ),
                    const SizedBox(height: 16),

                    // 📍 Campo de Texto: Ubicación
                    TextFormField(
                      controller: _ubicacionController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación (Ej: Av. Amazonas y Patria)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor ingresa la ubicación'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // 📝 Campo de Texto: Descripción
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '¿Qué está ocurriendo? Descríbelo aquí...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Por favor detalla el incidente'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // 🔘 Botón de Enviar a Firebase
                    ElevatedButton(
                      onPressed: _subiendo ? null : _enviarReporte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _subiendo
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Enviar Reporte en Tiempo Real',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
