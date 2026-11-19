import 'package:flutter/material.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/tarjeta_formulario.dart';
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
          content: Text('Cuenta creada. Te enviamos un correo de verificación'),
          duration: Duration(seconds: 4),
        ),
      );
      Navigator.popUntil(context, (ruta) => ruta.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cargando = context.watch<SesionProvider>().cargando;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            EncabezadoCurvo(
              alto: 215,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 24, 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text(
                          'CREAR CUENTA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
                        controller: conNombre,
                        validator: (v) => Validadores.requerido(v, 'El nombre'),
                        decoration: decoracionCampo('Nombre completo', Icons.person),
                      ),
                      const SizedBox(height: 14),
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
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: conPwd2,
                        obscureText: true,
                        validator: (v) =>
                            v != conPwd.text ? 'Las contraseñas no coinciden' : null,
                        decoration: decoracionCampo('Confirmar contraseña', Icons.lock_outline),
                      ),
                      const SizedBox(height: 22),
                      BotonPrincipal(
                        texto: 'CREAR CUENTA',
                        icono: Icons.people,
                        cargando: cargando,
                        onPressed: _registrar,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
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
