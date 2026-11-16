import 'package:flutter/material.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:provider/provider.dart';

/// Envuelve toda la app: cada toque corto hace "tic" (sfx_toque).
/// No suena mientras se muestra la pantalla de carga.
class ToqueSonoro extends StatelessWidget {
  final Widget child;

  const ToqueSonoro({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: SonidosService.m_punteroAbajo,
      onPointerUp: (e) {
        if (!context.read<PreferenciasProvider>().splashTerminado) {
          SonidosService.m_olvidaPuntero();
          return;
        }
        SonidosService.m_punteroArriba(e);
      },
      child: child,
    );
  }
}
