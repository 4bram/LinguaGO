import 'package:flutter/material.dart';
import 'package:lingua_go/components/pantalla_auth.dart';
import 'package:lingua_go/components/validadores.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _form = GlobalKey<FormState>();
  final conNombre = TextEditingController();
  final conUser = TextEditingController();
  final conPwd = TextEditingController();
  final conPwd2 = TextEditingController();

  @override
  void dispose() {
    conNombre.dispose();
    conUser.dispose();
    conPwd.dispose();
    conPwd2.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_form.currentState!.validate()) return;
    final error = await context.read<SesionProvider>().m_registra(
          conNombre.text.trim(),
          conUser.text.trim(),
          conPwd.text,
        );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), duration: const Duration(seconds: 3)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta creada, revisa tu correo'),
          duration: Duration(seconds: 4),
        ),
      );

      Navigator.popUntil(context, (ruta) => ruta.isFirst);
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
            const TituloAuth('Crear cuenta'),
            const SizedBox(height: 28),
            CampoAuth(
              controller: conNombre,
              hint: 'Nombre completo',
              icono: Icons.person_outline,
              validator: (v) => Validadores.requerido(v, 'Nombre'),
            ),
            const SizedBox(height: 12),
            CampoAuth(
              controller: conUser,
              hint: 'tucorreo@gmail.com',
              icono: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validator: Validadores.correo,
            ),
            const SizedBox(height: 24),
            CampoAuth(
              controller: conPwd,
              hint: 'Contrasena',
              icono: Icons.lock_outline,
              esPassword: true,
              validator: Validadores.password,
            ),
            const SizedBox(height: 12),
            CampoAuth(
              controller: conPwd2,
              hint: 'Confirmar contrasena',
              icono: Icons.lock_outline,
              esPassword: true,
              validator: (v) => v != conPwd.text ? 'No coinciden las contrasenas' : null,
            ),
            const SizedBox(height: 24),
            BotonAuth(texto: 'Crear cuenta', cargando: cargando, onPressed: _registrar),
            const SizedBox(height: 10),
            Center(
              child: EnlaceAuth(
                accion: 'Ya tengo cuenta',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
