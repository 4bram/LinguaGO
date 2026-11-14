import 'package:flutter/material.dart';
import 'package:lingua_go/components/theme_app.dart';

/// Barra de carga de la pantalla de inicio (degradado + brillo).
/// Inspirada en la barra de la app de referencia, con widgets básicos.
class BarraCarga extends StatelessWidget {
  final double valor;
  final double ancho;

  const BarraCarga({super.key, required this.valor, this.ancho = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: valor.clamp(0.0, 1.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, ThemeApp.lila],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progreso con degradado que se llena con animación
/// (capítulos, tarjetas de vocabulario, medidor del sensor).
class BarraProgreso extends StatelessWidget {
  final double valor;
  final double alto;

  const BarraProgreso({super.key, required this.valor, this.alto = 8});

  @override
  Widget build(BuildContext context) {
    final v = valor.clamp(0.0, 1.0).toDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: alto,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: ThemeApp.morado.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(alto),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: alto,
              width: constraints.maxWidth * v,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ThemeApp.morado, ThemeApp.lila],
                ),
                borderRadius: BorderRadius.circular(alto),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Indicador de "cargando" para listas: barra animada + texto.
class CargandoBarra extends StatelessWidget {
  final String texto;

  const CargandoBarra({super.key, this.texto = 'Cargando…'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 200,
              height: 6,
              child: LinearProgressIndicator(
                color: ThemeApp.lila,
                backgroundColor: ThemeApp.morado.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(texto, style: const TextStyle(fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }
}
