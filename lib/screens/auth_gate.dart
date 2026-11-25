import 'package:flutter/material.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/screens/carga_screen.dart';
import 'package:lingua_go/screens/dashboard_screen.dart';
import 'package:lingua_go/screens/login_screen.dart';
import 'package:lingua_go/screens/onboarding_screen.dart';
import 'package:lingua_go/screens/verificar_correo_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferenciasProvider>();
    final sesion = context.watch<SesionProvider>();

    if (!pref.splashTerminado) return const PantallaCarga();

    if (!pref.cargado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (sesion.usuario == null) return const LoginScreen();
    if (!sesion.correoVerificado) return const VerificarCorreoScreen();
    if (sesion.bienvenidaPendiente) {
      return OnboardingScreen(bienvenida: true, nombre: sesion.nombreCorto);
    }
    return const DashboardScreen();
  }
}
