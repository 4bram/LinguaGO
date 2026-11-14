/// Plan de suscripción (modelo de prestación de servicios).
class PlanModel {
  final String id;
  final String nombre;
  final String descripcion;
  final int precio; // MXN
  final int meses;
  final List<String> beneficios;
  final bool destacado;

  const PlanModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.meses,
    required this.beneficios,
    this.destacado = false,
  });

  /// Tres modalidades distintas (requisito del proyecto).
  static const List<PlanModel> planes = [
    PlanModel(
      id: 'mensual',
      nombre: 'Mensual',
      descripcion: 'Ideal para probar la plataforma',
      precio: 99,
      meses: 1,
      beneficios: [
        'Acceso a todas las unidades',
        'Ejercicios de vocabulario',
        'Notificaciones de recordatorio',
      ],
    ),
    PlanModel(
      id: 'trimestral',
      nombre: 'Trimestral',
      descripcion: 'El más popular',
      precio: 249,
      meses: 3,
      destacado: true,
      beneficios: [
        'Todo lo del plan mensual',
        'Ahorra 16 % vs. mensual',
        'Seguimiento de progreso avanzado',
      ],
    ),
    PlanModel(
      id: 'anual',
      nombre: 'Anual',
      descripcion: 'Mejor precio por mes',
      precio: 799,
      meses: 12,
      beneficios: [
        'Todo lo del plan trimestral',
        'Ahorra 33 % vs. mensual',
        'Contenido nuevo antes que nadie',
      ],
    ),
  ];

  static PlanModel? m_porId(String id) {
    for (final p in planes) {
      if (p.id == id) return p;
    }
    return null;
  }
}
