import 'package:flutter/material.dart';

/// Utilidades para diseño responsivo (móvil / escritorio).
class Responsivo {
  static const double anchoEscritorio = 800;

  static bool esEscritorio(BuildContext context) =>
      MediaQuery.of(context).size.width >= anchoEscritorio;
}

/// Centra el contenido y limita su ancho (en escritorio se ve como la
/// "pantalla de teléfono" del diseño).
class ContenedorCentrado extends StatelessWidget {
  final Widget child;
  final double anchoMaximo;

  const ContenedorCentrado({
    super.key,
    required this.child,
    this.anchoMaximo = 520,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}
