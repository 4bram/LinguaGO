import 'dart:math';
import 'package:flutter/material.dart';

class AnilloProgreso extends StatelessWidget {
  final int porcentaje;
  final double tam;
  final Color color;

  const AnilloProgreso({
    super.key,
    required this.porcentaje,
    this.tam = 40,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tam,
      height: tam,
      child: CustomPaint(
        painter: _AnilloPainter(porcentaje / 100, color),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tam * 0.14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$porcentaje%',
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: color,
                  fontSize: tam * 0.24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnilloPainter extends CustomPainter {
  final double avance;
  final Color color;

  _AnilloPainter(this.avance, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2 - 3;

    final fondo = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(centro, radio, fondo);

    final arco = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -pi / 2,
      2 * pi * avance,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(covariant _AnilloPainter old) =>
      old.avance != avance || old.color != color;
}
