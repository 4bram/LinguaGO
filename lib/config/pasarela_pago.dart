import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ResultadoPago {
  final bool exito;
  final String mensaje;
  final String? idTransaccion;

  const ResultadoPago({
    required this.exito,
    required this.mensaje,
    this.idTransaccion,
  });
}

class _ErrorStripe implements Exception {
  final String mensaje;
  const _ErrorStripe(this.mensaje);
}

/// Pasarela de pagos con Stripe (API REST, MODO PRUEBA).
///
/// Flujo: 1) se crea un PaymentMethod con los datos capturados en la pantalla
/// nativa de pago y 2) se crea y confirma un PaymentIntent. El resultado
/// ("succeeded") es el que activa la suscripción o registra el pedido.
///
/// La clave se lee de `.env` (`STRIPE_SECRET_KEY=sk_test_...`).
/// ADVERTENCIA: una clave secreta dentro de una app móvil puede extraerse.
/// Por eso SOLO se aceptan claves de prueba (`sk_test_`); una clave `sk_live_`
/// se rechaza. En producción, el PaymentIntent debe crearlo un backend.
///
/// Sin clave configurada la app sigue funcionando en modo demostración local.
class PasarelaPago {
  static const String _base = 'https://api.stripe.com/v1';

  /// Tarjetas de prueba oficiales de Stripe -> token de método de pago de prueba.
  /// Con estos tokens NO se envía el número de tarjeta a la API (por eso no
  /// hace falta activar "Raw card data APIs" en el Dashboard).
  static const Map<String, String> _tarjetasPrueba = {
    '4242424242424242': 'pm_card_visa',
    '4000056655665556': 'pm_card_visa_debit',
    '5555555555554444': 'pm_card_mastercard',
    '2223003122003222': 'pm_card_mastercard',
    '5200828282828210': 'pm_card_mastercard_debit',
    '378282246310005': 'pm_card_amex',
    '6011111111111117': 'pm_card_discover',
    '4000000000000002': 'pm_card_chargeDeclined',
    '4000000000009995': 'pm_card_chargeDeclinedInsufficientFunds',
    '4000000000000069': 'pm_card_chargeDeclinedExpiredCard',
    '4000000000000127': 'pm_card_chargeDeclinedIncorrectCvc',
  };

  String get _clave {
    try {
      return (dotenv.maybeGet('STRIPE_SECRET_KEY') ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  bool get _claveEnVivo =>
      _clave.startsWith('sk_live_') || _clave.startsWith('rk_live_');

  /// true cuando no hay una clave de prueba válida (se simula el pago).
  bool get modoSimulado => !_clave.startsWith('sk_test_');

  Future<ResultadoPago> m_procesaPago({
    required int montoMxn,
    required String descripcion,
    required String titular,
    required String numero,
    required int mes,
    required int anio,
    required String cvv,
    Map<String, String> metadata = const {},
  }) async {
    if (_claveEnVivo) {
      return const ResultadoPago(
        exito: false,
        mensaje: 'Por seguridad solo se aceptan claves de prueba de Stripe '
            '(sk_test_...). No se realizó ningún cargo.',
      );
    }
    if (modoSimulado) return _simula(numero);

    try {
      // 1) Método de pago. Tarjeta de prueba conocida -> token de Stripe.
      //    Otra tarjeta -> se intenta crear con los datos capturados.
      final token = _tarjetasPrueba[numero];
      final String metodoId;
      if (token != null) {
        metodoId = token;
      } else {
        final metodo = await _post('payment_methods', {
          'type': 'card',
          'card[number]': numero,
          'card[exp_month]': '$mes',
          'card[exp_year]': '$anio',
          'card[cvc]': cvv,
          'billing_details[name]': titular,
        });
        metodoId = '${metodo['id']}';
      }

      // 2) Pago (PaymentIntent confirmado de inmediato)
      final intento = await _post(
        'payment_intents',
        {
          'amount': '${montoMxn * 100}', // centavos
          'currency': 'mxn',
          'payment_method': metodoId,
          'confirm': 'true',
          'description': descripcion,
          'automatic_payment_methods[enabled]': 'true',
          'automatic_payment_methods[allow_redirects]': 'never',
          for (final e in metadata.entries) 'metadata[${e.key}]': e.value,
        },
        idempotencia: 'lg_${DateTime.now().microsecondsSinceEpoch}',
      );

      final estado = '${intento['status']}';
      if (estado == 'succeeded') {
        return ResultadoPago(
          exito: true,
          mensaje: 'Pago aprobado por Stripe (modo prueba).',
          idTransaccion: '${intento['id']}',
        );
      }
      if (estado == 'requires_action') {
        return const ResultadoPago(
          exito: false,
          mensaje: 'La tarjeta pide autenticación adicional (3D Secure). '
              'Usa otra tarjeta de prueba.',
        );
      }
      return ResultadoPago(
        exito: false,
        mensaje: 'El pago no se completó (estado: $estado).',
      );
    } on _ErrorStripe catch (e) {
      return ResultadoPago(exito: false, mensaje: e.mensaje);
    } on TimeoutException {
      return const ResultadoPago(
        exito: false,
        mensaje: 'Stripe tardó demasiado en responder. Intenta de nuevo.',
      );
    } catch (_) {
      return const ResultadoPago(
        exito: false,
        mensaje: 'No se pudo conectar con Stripe. Revisa tu conexión.',
      );
    }
  }

  Future<Map<String, dynamic>> _post(
    String ruta,
    Map<String, String> cuerpo, {
    String? idempotencia,
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$_base/$ruta'),
          headers: {
            'Authorization': 'Bearer $_clave',
            'Idempotency-Key': ?idempotencia,
          },
          body: cuerpo,
        )
        .timeout(const Duration(seconds: 30));

    final datos = jsonDecode(respuesta.body);
    if (datos is! Map<String, dynamic>) {
      throw const _ErrorStripe('Respuesta inesperada de Stripe.');
    }
    if (respuesta.statusCode >= 400) {
      final error = datos['error'];
      throw _ErrorStripe(
        _traduce(error is Map ? Map<String, dynamic>.from(error) : {}),
      );
    }
    return datos;
  }

  String _traduce(Map<String, dynamic> error) {
    const mapa = <String, String>{
      'card_declined': 'La tarjeta fue rechazada.',
      'generic_decline': 'La tarjeta fue rechazada.',
      'insufficient_funds': 'La tarjeta no tiene fondos suficientes.',
      'lost_card': 'La tarjeta fue rechazada.',
      'stolen_card': 'La tarjeta fue rechazada.',
      'expired_card': 'La tarjeta está vencida.',
      'incorrect_cvc': 'El código de seguridad (CVV) es incorrecto.',
      'incorrect_number': 'El número de tarjeta es incorrecto.',
      'invalid_number': 'El número de tarjeta es inválido.',
      'invalid_expiry_month': 'El mes de vencimiento es inválido.',
      'invalid_expiry_year': 'El año de vencimiento es inválido.',
      'processing_error': 'Error al procesar la tarjeta. Intenta de nuevo.',
    };
    for (final campo in ['decline_code', 'code']) {
      final codigo = '${error[campo] ?? ''}';
      if (mapa.containsKey(codigo)) return '${mapa[codigo]} No se realizó ningún cargo.';
    }
    final mensaje = '${error['message'] ?? 'Error desconocido de Stripe.'}';
    if (mensaje.toLowerCase().contains('raw card data')) {
      return 'Stripe solo acepta aquí tarjetas de prueba oficiales. Usa '
          '4242 4242 4242 4242 (aprobada) o 4000 0000 0000 0002 (rechazada).';
    }
    return mensaje;
  }

  /// Modo demostración local (cuando no hay clave de prueba en el .env).
  Future<ResultadoPago> _simula(String numero) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (numero.endsWith('0002')) {
      return const ResultadoPago(
        exito: false,
        mensaje: 'Pago rechazado (simulación de prueba). No se realizó ningún cargo.',
      );
    }
    return ResultadoPago(
      exito: true,
      mensaje: 'Pago aprobado en modo demostración. No se realizó ningún cargo real.',
      idTransaccion: 'demo_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
