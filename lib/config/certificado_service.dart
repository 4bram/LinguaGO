import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Dibuja el certificado de una unidad aprobada como imagen PNG
/// (Canvas + PictureRecorder, sin librerías extra). Después se sube a
/// Supabase Storage y se muestra en "Mis certificados".
class CertificadoService {
  static const double _w = 1400;
  static const double _h = 990;
  static const Color _morado = Color(0xFF4C1FE0);
  static const Color _lila = Color(0xFFB45CF0);

  static const List<String> _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  double _texto(
    Canvas c,
    String texto,
    double y,
    double tam,
    Color color, {
    FontWeight peso = FontWeight.w500,
    FontStyle estilo = FontStyle.normal,
    double espacio = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontSize: tam,
          color: color,
          fontWeight: peso,
          fontStyle: estilo,
          letterSpacing: espacio,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: _w - 220);
    tp.paint(c, Offset((_w - tp.width) / 2, y));
    return tp.height;
  }

  Future<Uint8List> m_genera({
    required String nombre,
    required String unidad,
    required int unidadNumero,
    required int porcentaje,
    required DateTime fecha,
  }) async {
    final rec = ui.PictureRecorder();
    final c = Canvas(rec, const Rect.fromLTWH(0, 0, _w, _h));

    // Fondo y franja superior con degradado
    c.drawRect(const Rect.fromLTWH(0, 0, _w, _h), Paint()..color = const Color(0xFFFFFFFF));
    c.drawRect(
      const Rect.fromLTWH(0, 0, _w, 190),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(_w, 190),
          [_morado, _lila],
        ),
    );
    // Círculos decorativos
    c.drawCircle(const Offset(_w - 120, 40), 130, Paint()..color = const Color(0x22FFFFFF));
    c.drawCircle(const Offset(110, 170), 90, Paint()..color = const Color(0x18FFFFFF));

    // Marco
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(34, 34, _w - 68, _h - 68),
        const Radius.circular(28),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = _morado,
    );

    _texto(c, 'LinguaGo', 52, 70, Colors.white, peso: FontWeight.w800, espacio: 2);
    _texto(c, 'ACADEMIA DE INGLÉS', 132, 26, const Color(0xCCFFFFFF), espacio: 6);

    _texto(c, 'CERTIFICADO DE APROBACIÓN', 250, 54, _morado, peso: FontWeight.w800, espacio: 2);
    _texto(c, 'Se otorga a', 340, 30, const Color(0xFF555555));
    final hNombre = _texto(c, nombre, 392, 74, const Color(0xFF1B1B1B), peso: FontWeight.w800);
    var y = 392 + hNombre + 8;
    c.drawLine(
      Offset(_w / 2 - 330, y),
      Offset(_w / 2 + 330, y),
      Paint()
        ..color = _lila
        ..strokeWidth = 3,
    );
    y += 26;
    _texto(c, 'por aprobar la evaluación final de la', y, 30, const Color(0xFF555555));
    y += 52;
    final hUnidad = _texto(
      c,
      'UNIDAD $unidadNumero · ${unidad.toUpperCase()}',
      y,
      46,
      _morado,
      peso: FontWeight.w800,
    );
    y += hUnidad + 22;
    _texto(c, 'con una calificación de $porcentaje %', y, 34, const Color(0xFF333333), peso: FontWeight.w600);

    // Sello
    const centro = Offset(_w / 2, 800);
    c.drawCircle(centro, 78, Paint()..color = _lila.withValues(alpha: .15));
    c.drawCircle(
      centro,
      78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = _morado,
    );
    final sello = TextPainter(
      text: const TextSpan(
        text: '★',
        style: TextStyle(fontSize: 90, color: _morado),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    sello.paint(c, Offset(centro.dx - sello.width / 2, centro.dy - sello.height / 2));

    final fechaTxt = '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
    _texto(c, 'Expedido el $fechaTxt', 905, 28, const Color(0xFF555555), estilo: FontStyle.italic);

    final img = await rec.endRecording().toImage(_w.toInt(), _h.toInt());
    final datos = await img.toByteData(format: ui.ImageByteFormat.png);
    return datos!.buffer.asUint8List();
  }
}
