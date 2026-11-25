import 'package:flutter/material.dart';
import 'package:lingua_go/components/pantalla_auth.dart';
import 'package:lingua_go/components/validadores.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final conUser = TextEditingController();

  @override
  void dispose() {
    conUser.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final error = await context
        .read<SesionProvider>()
        .m_recuperaPassword(conUser.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Revisa tu correo para cambiar la contrasena'),
        duration: const Duration(seconds: 4),
      ),
    );
    if (error == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<SesionProvider>().cargando;

    return PantallaAuth(
      conAtras: true,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloAuth(
              'Recuperar contrasena',
              detalle: 'Escribe tu correo y te mandamos un enlace',
            ),
            const SizedBox(height: 28),
            CampoAuth(
              controller: conUser,
              hint: 'tucorreo@gmail.com',
              icono: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validator: Validadores.correo,
            ),
            const SizedBox(height: 18),
            BotonAuth(texto: 'Enviar enlace', cargando: cargando, onPressed: _enviar),
          ],
        ),
      ),
    );
  }
}
