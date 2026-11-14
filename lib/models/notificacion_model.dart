/// Notificación recibida por FCM (para el historial dentro de la app).
class NotificacionModel {
  final String titulo;
  final String cuerpo;
  final String estado; // Primer plano / Segundo plano / App cerrada
  final DateTime fecha;

  NotificacionModel({
    required this.titulo,
    required this.cuerpo,
    required this.estado,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();
}
