import 'package:flutter/material.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/screens/carga_screen.dart';
import 'package:lingua_go/screens/dashboard_screen.dart';
import 'package:lingua_go/screens/login_screen.dart';
import 'package:lingua_go/screens/onboarding_screen.dart';
import 'package:lingua_go/screens/verificar_correo_screen.dart';
import 'package:provider/provider.dart';

/// Decide qué pantalla mostrar:
/// onboarding -> login -> verificación de correo -> dashboard.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferenciasProvider>();
    final sesion = context.watch<SesionProvider>();

    // Pantalla de carga inicial con barra
    if (!pref.splashTerminado) return const PantallaCarga();

    if (!pref.cargado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!pref.onboardingVisto) return const OnboardingScreen();
    if (sesion.usuario == null) return const LoginScreen();
    if (!sesion.correoVerificado) return const VerificarCorreoScreen();
    return const DashboardScreen();
  }
}
