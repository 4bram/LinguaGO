import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/barras.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:provider/provider.dart';

/// Pantalla de carga inicial (~3 s): logo flotando, barra de carga con
/// degradado y texto que parpadea suave. Al terminar entra a la app.
class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    SonidosService.m_inicio(); // sonido de inicio (inicio.wav)
  }

  @override
  void dispose() {
    SonidosService.m_detieneInicio();
    super.dispose();
  }

  double _tramo(double v, double a, double b, Curve curva) {
    return curva.transform(((v - a) / (b - a)).clamp(0.0, 1.0).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 60000),
      onEnd: () => context.read<PreferenciasProvider>().m_terminaSplash(),
      builder: (context, v, _) {
        final logo = _tramo(v, 0.0, 0.3, Curves.easeOutBack);
        final texto = _tramo(v, 0.2, 0.45, Curves.easeOutCubic);
        final barra = _tramo(v, 0.08, 0.95, Curves.easeInOut);
        final flota = sin(v * 2 * pi * 4) * 6;
        final parpadeo = 0.6 + 0.4 * (0.5 + 0.5 * sin(v * 2 * pi * 5));

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeApp.morado, ThemeApp.moradoClaro, ThemeApp.lila],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -50,
                  child: CircleAvatar(
                    radius: 130,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                Positioned(
                  bottom: -70,
                  left: -60,
                  child: CircleAvatar(
                    radius: 120,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: logo.clamp(0.0, 1.0).toDouble(),
                        child: Transform.translate(
                          offset: Offset(0, flota),
                          child: Transform.scale(
                            scale: 0.6 + 0.4 * logo,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 30,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.asset(
                                  'assets/icon/logo.png',
                                  width: 190,
                                  height: 190,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: texto,
                        child: Transform.translate(
                          offset: Offset(0, (1 - texto) * 14),
                          child: const Text(
                            'Aprende inglés fácil y rápido',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      BarraCarga(valor: barra),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: parpadeo,
                        child: const Text(
                          'Cargando tu curso…',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
