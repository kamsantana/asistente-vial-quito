import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/report_notifier.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  @override
  void initState() {
    super.initState();
    // Ejecuta la carga automática de los reportes al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportNotifier>().loadReports();
    });
  }

  // Define un color dinámico basado en la gravedad evaluada por Gemini
  Color _getGravedadColor(String nivel) {
    switch (nivel.toUpperCase()) {
      case 'ALTO':
        return Colors.redAccent;
      case 'MEDIO':
        return Colors.orangeAccent;
      case 'BAJO':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Viales Inteligentes'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportNotifier>().loadReports(),
          ),
        ],
      ),
      body: Consumer<ReportNotifier>(
        builder: (context, notifier, child) {
          switch (notifier.state) {
            case ReportState.initial:
            case ReportState.loading:
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );

            case ReportState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        notifier.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () => notifier.loadReports(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );

            case ReportState.loaded:
              if (notifier.reports.isEmpty) {
                return const Center(
                  child: Text('No hay incidentes viales reportados en Quito.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifier.reports.length,
                itemBuilder: (context, index) {
                  final report = notifier.reports[index];
                  final colorGravedad = _getGravedadColor(report.nivelGravedad);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.titulo,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorGravedad.withOpacity(0.2),
                                  border: Border.all(color: colorGravedad),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  report.nivelGravedad,
                                  style: TextStyle(
                                    color: colorGravedad,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: const [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Resumen Inteligente:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            report.resumenIa,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
