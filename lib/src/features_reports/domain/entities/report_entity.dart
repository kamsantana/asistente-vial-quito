class ReportEntity {
  final String id;
  final String titulo;
  final String resumenIa;
  final String nivelGravedad;

  ReportEntity({
    required this.id,
    required this.titulo,
    required this.resumenIa,
    required this.nivelGravedad,
  });

  factory ReportEntity.fromJson(Map<String, dynamic> json) {
    return ReportEntity(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? 'Sin título',
      resumenIa: json['resumen_ia'] ?? 'Sin resumen disponible.',
      nivelGravedad: json['nivel_gravedad'] ?? 'MEDIO',
    );
  }
}
