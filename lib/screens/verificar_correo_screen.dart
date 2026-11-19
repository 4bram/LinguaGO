import 'package:flutter/material.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/tarjeta_formulario.dart';
import 'package:lingua_go/config/sonidos_service.dart';
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
      _mensaje(context, 'Aún no se ha confirmado el correo. Revisa tu bandeja y spam.');
    }
  }

  Future<void> _reenviar(BuildContext context) async {
    final error = await context.read<SesionProvider>().m_reenviaVerificacion();
    if (context.mounted) {
      if (error == null) SonidosService.m_exito();
      _mensaje(context, error ?? 'Correo de verificación reenviado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EncabezadoCurvo(
              alto: 230,
              child: const SafeArea(
                child: Center(
                  child: Icon(Icons.mark_email_unread, size: 90, color: Colors.white),
                ),
              ),
            ),
            TarjetaFormulario(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    const Text(
                      'Verifica tu correo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enviamos un enlace de confirmación a\n${sesion.correo}\n'
                      'Ábrelo y después presiona el botón de abajo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    BotonPrincipal(
                      texto: 'YA VERIFIQUÉ MI CORREO',
                      icono: Icons.check_circle,
                      cargando: sesion.cargando,
                      onPressed: () => _yaVerifique(context),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: sesion.cargando ? null : () => _reenviar(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Reenviar correo'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context.read<NavProvider>().m_cambia(0);
                        context.read<SesionProvider>().m_cerrarSesion();
                      },
                      child: const Text('Usar otra cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
