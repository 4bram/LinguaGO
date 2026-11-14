import 'package:flutter/material.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/tarjeta_formulario.dart';
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EncabezadoCurvo(
              alto: 270,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset('assets/icon/logo.png', height: 110),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Aprende inglés fácil y rápido',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TarjetaFormulario(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: conUser,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validadores.correo,
                        decoration: decoracionCampo('Correo', Icons.email),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: conPwd,
                        obscureText: true,
                        validator: Validadores.password,
                        decoration: decoracionCampo('Contraseña', Icons.lock),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/recuperar'),
                          child: const Text('¿Olvidaste tu contraseña?'),
                        ),
                      ),
                      BotonPrincipal(
                        texto: 'INICIAR SESIÓN',
                        icono: Icons.login,
                        cargando: cargando,
                        onPressed: _login,
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('o continúa con'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: cargando ? null : _google,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text('Google'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: cargando ? null : _github,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub'),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/signIn'),
                        child: Text(
                          'Crear cuenta',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
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
  }
}
