import 'package:flutter/material.dart';

/// WIDGET AVANZADO (innovación UI): recorte personalizado con curva
/// en la esquina inferior derecha, como en el diseño de referencia.
class CurvaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radio = 70;
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width - radio, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - radio,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
