import 'package:flutter/material.dart';

class Responsivo {
  static const double anchoEscritorio = 800;

  static bool esEscritorio(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= anchoEscritorio;

  static TamPantalla tam(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 600) return TamPantalla.compacta;
    if (w < 1024) return TamPantalla.media;
    return TamPantalla.expandida;
  }

  static bool esHorizontal(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool esBaja(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 480;

  static bool usaRiel(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    return s.width >= 720 || (s.width >= 560 && s.width > s.height);
  }

  static int columnas(double ancho, {double anchoMinimo = 320}) {
    final n = (ancho / anchoMinimo).floor();
    return n < 1 ? 1 : (n > 4 ? 4 : n);
  }
}

enum TamPantalla { compacta, media, expandida }

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
