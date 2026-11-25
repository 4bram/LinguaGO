import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApp {
  static const Color morado = Color(0xFF4A1FE8);
  static const Color moradoClaro = Color(0xFF6B3DF5);
  static const Color lila = Color(0xFFB45EF0);

  static ThemeData claro() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: morado,
        primary: morado,
        secondary: lila,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
    return base.copyWith(textTheme: GoogleFonts.ralewayTextTheme(base.textTheme));
  }

  static ThemeData oscuro() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: morado,
        primary: const Color(0xFF8E6BFF),
        secondary: lila,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF14111F),
    );
    return base.copyWith(textTheme: GoogleFonts.ralewayTextTheme(base.textTheme));
  }
}
