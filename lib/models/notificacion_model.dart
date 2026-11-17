class NotificacionModel {
  final String id;
  final String titulo;
  final String cuerpo;
  final String estado;
  final DateTime fecha;

  NotificacionModel({
    this.id = '',
    required this.titulo,
    required this.cuerpo,
    required this.estado,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'cuerpo': cuerpo,
        'estado': estado,
        'fecha': fecha.toIso8601String(),
      };

  factory NotificacionModel.fromMap(Map<String, dynamic> m) => NotificacionModel(
        id: '${m['id'] ?? ''}',
        titulo: '${m['titulo'] ?? 'Notificación'}',
        cuerpo: '${m['cuerpo'] ?? ''}',
        estado: '${m['estado'] ?? ''}',
        fecha: DateTime.tryParse('${m['fecha'] ?? ''}'),
      );
}
