import 'package:flutter/material.dart';
import 'package:lingua_go/components/pantalla_auth.dart';
import 'package:lingua_go/components/validadores.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final conUser = TextEditingController();
  final conPwd = TextEditingController();

  @override
  void dispose() {
    conUser.dispose();
    conPwd.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    final error = await context
        .read<SesionProvider>()
        .m_login(conUser.text.trim(), conPwd.text);
    if (error != null && mounted) _mensaje(error);
  }

  Future<void> _google() async {
    final error = await context.read<SesionProvider>().m_loginGoogle();
    if (error != null && mounted) _mensaje(error);
  }

  Future<void> _github() async {
    final error = await context.read<SesionProvider>().m_loginGithub();
    if (error != null && mounted) _mensaje(error);
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<SesionProvider>().cargando;

    return PantallaAuth(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloAuth('Iniciar sesion'),
            const SizedBox(height: 28),
            CampoAuth(
              controller: conUser,
              hint: 'tucorreo@gmail.com',
              icono: Icons.mail_outline,
              teclado: TextInputType.emailAddress,
              validator: Validadores.correo,
            ),
            const SizedBox(height: 12),
            CampoAuth(
              controller: conPwd,
              hint: 'Contrasena',
              icono: Icons.lock_outline,
              esPassword: true,
              validator: Validadores.password,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: EnlaceAuth(
                accion: 'Olvidaste tu contrasena?',
                onTap: () => Navigator.pushNamed(context, '/recuperar'),
              ),
            ),
            const SizedBox(height: 6),
            BotonAuth(texto: 'Iniciar sesion', cargando: cargando, onPressed: _login),
            const SizedBox(height: 26),
            const SeparadorAuth(),
            const SizedBox(height: 14),
            const Text('O entra con', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: BotonContornoAuth(
                    texto: 'Google',
                    icono: const IconoGoogle(),
                    onPressed: cargando ? null : _google,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BotonContornoAuth(
                    texto: 'GitHub',
                    icono: const Icon(Icons.code, size: 20, color: Colors.white),
                    onPressed: cargando ? null : _github,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: EnlaceAuth(
                texto: 'No tienes cuenta?',
                accion: 'Registrate',
                onTap: () => Navigator.pushNamed(context, '/signIn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
