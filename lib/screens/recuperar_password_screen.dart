import 'package:flutter/material.dart';
import 'package:lingua_go/components/botones_campos.dart';
import 'package:lingua_go/components/encabezado_curvo.dart';
import 'package:lingua_go/components/tarjeta_formulario.dart';
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
        content: Text(error ?? 'Te enviamos un correo para restablecer tu contraseña'),
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
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'RECUPERAR CONTRASEÑA',
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
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
                      const Text(
                        'Escribe el correo de tu cuenta y te enviaremos un enlace para crear una nueva contraseña.',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: conUser,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validadores.correo,
                        decoration: decoracionCampo('Correo', Icons.email),
                      ),
                      const SizedBox(height: 22),
                      BotonPrincipal(
                        texto: 'ENVIAR ENLACE',
                        icono: Icons.send,
                        cargando: cargando,
                        onPressed: _enviar,
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
