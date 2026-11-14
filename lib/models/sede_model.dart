import 'package:latlong2/latlong.dart';

/// Sede de la academia (datos de ejemplo editables).
class SedeModel {
  final String id;
  final String nombre;
  final String direccion;
  final String telefono;
  final LatLng ubicacion;
  final String horarioTexto;

  /// Horario por día de la semana (1 = lunes … 7 = domingo): [apertura, cierre] en horas.
  final Map<int, List<int>> horario;

  const SedeModel({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.ubicacion,
    required this.horarioTexto,
    required this.horario,
  });

  /// ¿Está abierta en este momento?
  bool m_abiertaAhora([DateTime? ahora]) {
    final t = ahora ?? DateTime.now();
    final h = horario[t.weekday];
    if (h == null) return false;
    final minutos = t.hour * 60 + t.minute;
    return minutos >= h[0] * 60 && minutos < h[1] * 60;
  }

  /// Texto "Cierra a las 20:00" / "Abre mañana…" para el distintivo.
  String m_estadoTexto([DateTime? ahora]) {
    final t = ahora ?? DateTime.now();
    final h = horario[t.weekday];
    if (m_abiertaAhora(t)) return 'Abierto · cierra a las ${h![1]}:00';
    if (h != null && t.hour < h[0]) return 'Cerrado · abre hoy a las ${h[0]}:00';
    for (var d = 1; d <= 7; d++) {
      final dia = (t.weekday - 1 + d) % 7 + 1;
      final hd = horario[dia];
      if (hd != null) {
        const nombres = ['', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
        return 'Cerrado · abre ${d == 1 ? 'mañana' : nombres[dia]} a las ${hd[0]}:00';
      }
    }
    return 'Cerrado';
  }

  static const Map<int, List<int>> _lunVie = {
    1: [9, 20], 2: [9, 20], 3: [9, 20], 4: [9, 20], 5: [9, 20],
  };
  static const Map<int, List<int>> _lunSab = {
    1: [8, 21], 2: [8, 21], 3: [8, 21], 4: [8, 21], 5: [8, 21], 6: [9, 14],
  };

  static const List<SedeModel> sedes = [
    SedeModel(
      id: 'centro',
      nombre: 'LinguaGo Academy · Centro',
      direccion: 'Jardín Principal, Centro, Celaya, Gto.',
      telefono: '+524616000001',
      ubicacion: LatLng(20.5233, -100.8155),
      horarioTexto: 'Lun - Vie 9:00 a 20:00 h',
      horario: _lunVie,
    ),
    SedeModel(
      id: 'norte',
      nombre: 'LinguaGo Campus · Norte',
      direccion: 'Zona Norte, Celaya, Gto. (sede de ejemplo)',
      telefono: '+524616000002',
      ubicacion: LatLng(20.5420, -100.8130),
      horarioTexto: 'Lun - Vie 8:00 a 21:00 h · Sáb 9:00 a 14:00 h',
      horario: _lunSab,
    ),
    SedeModel(
      id: 'sur',
      nombre: 'LinguaGo Express · Sur',
      direccion: 'Zona Sur, Celaya, Gto. (sede de ejemplo)',
      telefono: '+524616000003',
      ubicacion: LatLng(20.5050, -100.8250),
      horarioTexto: 'Lun - Vie 9:00 a 20:00 h',
      horario: _lunVie,
    ),
  ];
}
