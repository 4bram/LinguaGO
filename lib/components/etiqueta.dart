import 'package:flutter/material.dart';

class Etiqueta extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color colorTexto;
  final IconData? icono;

  const Etiqueta(
    this.texto, {
    super.key,
    this.fondo = Colors.amber,
    this.colorTexto = Colors.black87,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 11, color: colorTexto),
            const SizedBox(width: 3),
          ],
          Text(
            texto,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: colorTexto,
            ),
          ),
        ],
      ),
    );
  }
}
