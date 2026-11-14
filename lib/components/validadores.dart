import 'package:flutter/services.dart';

/// Validaciones de formularios (registro, login y tarjeta de pago).
class Validadores {
  static String? requerido(String? v, [String campo = 'Este campo']) {
    if (v == null || v.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Correo no válido';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Algoritmo de Luhn para números de tarjeta.
  static bool luhn(String numero) {
    int suma = 0;
    bool alterna = false;
    for (int i = numero.length - 1; i >= 0; i--) {
      int d = int.parse(numero[i]);
      if (alterna) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      suma += d;
      alterna = !alterna;
    }
    return suma % 10 == 0;
  }

  static String? tarjeta(String? v) {
    final limpio = (v ?? '').replaceAll(' ', '');
    if (limpio.isEmpty) return 'El número es obligatorio';
    if (limpio.length != 16) return 'Debe tener 16 dígitos';
    if (!luhn(limpio)) return 'Número de tarjeta inválido';
    return null;
  }

  static String? expiracion(String? v) {
    if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
      return 'Formato MM/AA';
    }
    final mes = int.parse(v.substring(0, 2));
    final anio = 2000 + int.parse(v.substring(3));
    if (mes < 1 || mes > 12) return 'Mes inválido';
    final finDeMes = DateTime(anio, mes + 1, 1);
    if (!finDeMes.isAfter(DateTime.now())) return 'Tarjeta vencida';
    return null;
  }

  static String? cvv(String? v) {
    if (v == null || !RegExp(r'^\d{3,4}$').hasMatch(v)) return 'CVV inválido';
    return null;
  }
}

/// Da formato "1234 5678 9012 3456" mientras se escribe.
class FormatoTarjeta extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue viejo,
    TextEditingValue nuevo,
  ) {
    final digitos = nuevo.text.replaceAll(RegExp(r'\D'), '');
    final limitado = digitos.length > 16 ? digitos.substring(0, 16) : digitos;
    final sb = StringBuffer();
    for (int i = 0; i < limitado.length; i++) {
      if (i > 0 && i % 4 == 0) sb.write(' ');
      sb.write(limitado[i]);
    }
    final texto = sb.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Da formato "MM/AA" mientras se escribe.
class FormatoExpira extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue viejo,
    TextEditingValue nuevo,
  ) {
    final digitos = nuevo.text.replaceAll(RegExp(r'\D'), '');
    final limitado = digitos.length > 4 ? digitos.substring(0, 4) : digitos;
    String texto = limitado;
    if (limitado.length > 2) {
      texto = '${limitado.substring(0, 2)}/${limitado.substring(2)}';
    }
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
