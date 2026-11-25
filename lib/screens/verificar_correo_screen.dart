import 'package:flutter/material.dart';
import 'package:lingua_go/components/pantalla_auth.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

class VerificarCorreoScreen extends StatelessWidget {
  const VerificarCorreoScreen({super.key});

  void _mensaje(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _yaVerifique(BuildContext context) async {
    final sesion = context.read<SesionProvider>();
    await sesion.m_recargaUsuario();
    if (context.mounted && !sesion.correoVerificado) {
      _mensaje(context, 'Todavia no verificas tu correo');
    }
  }

  Future<void> _reenviar(BuildContext context) async {
    final error = await context.read<SesionProvider>().m_reenviaVerificacion();
    if (context.mounted) {
      _mensaje(context, error ?? 'Correo reenviado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();

    return PantallaAuth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloAuth(
            'Verifica tu correo',
            detalle: 'Te mandamos un correo a\n${sesion.correo}\nverificalo y presiona el boton',
          ),
          const SizedBox(height: 28),
          BotonAuth(
            texto: 'Ya verifique mi correo',
            cargando: sesion.cargando,
            onPressed: () => _yaVerifique(context),
          ),
          const SizedBox(height: 12),
          BotonContornoAuth(
            texto: sesion.puedeReenviar
                ? 'Reenviar correo'
                : 'Reenviar en ${sesion.segundosReenvio} s',
            icono: const Icon(Icons.send, size: 18, color: Colors.white),
            onPressed: (sesion.cargando || !sesion.puedeReenviar)
                ? null
                : () => _reenviar(context),
          ),
          const SizedBox(height: 10),
          Center(
            child: EnlaceAuth(
              accion: 'Usar otra cuenta',
              onTap: () {
                context.read<NavProvider>().m_cambia(0);
                context.read<SesionProvider>().m_cerrarSesion();
              },
            ),
          ),
        ],
      ),
    );
  }
}
