import 'package:flutter/services.dart';

class Validadores {
  static String? requerido(String? v, [String campo = 'Este campo']) {
    if (v == null || v.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Correo obligatorio';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Correo no valido';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Contrasena obligatoria';
    if (v.length < 6) return 'Min 6 caracteres';
    return null;
  }

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
    if (limpio.isEmpty) return 'Numero obligatorio';
    if (limpio.length != 16) return 'Debe tener 16 digitos';
    if (!luhn(limpio)) return 'Num de tarjeta invalido';
    return null;
  }

  static String? expiracion(String? v) {
    if (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) {
      return 'Formato MM/AA';
    }
    final mes = int.parse(v.substring(0, 2));
    final anio = 2000 + int.parse(v.substring(3));
    if (mes < 1 || mes > 12) return 'Mes invalido';
    final finDeMes = DateTime(anio, mes + 1, 1);
    if (!finDeMes.isAfter(DateTime.now())) return 'Tarjeta vencida';
    return null;
  }

  static String? cvv(String? v) {
    if (v == null || !RegExp(r'^\d{3,4}$').hasMatch(v)) return 'CVV invalido';
    return null;
  }
}

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
