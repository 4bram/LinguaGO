import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/pasarela_pago.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/models/plan_model.dart';

/// Suscripción del usuario y proceso de pago.
class SuscripcionProvider extends ChangeNotifier {
  final FirestoreUsuario _fs = FirestoreUsuario();
  final PasarelaPago _pasarela = PasarelaPago();

  Map<String, dynamic>? suscripcion;
  bool procesando = false;
  String? _uid;
  StreamSubscription<Map<String, dynamic>?>? _sub;

  bool get modoSimulado => _pasarela.modoSimulado;

  DateTime? get fechaFin =>
      DateTime.tryParse((suscripcion?['fechaFin'] ?? '').toString());

  bool get activa => fechaFin != null && fechaFin!.isAfter(DateTime.now());

  String get nombrePlan => (suscripcion?['nombrePlan'] ?? '').toString();

  String get idPlan => (suscripcion?['idPlan'] ?? '').toString();

  void m_iniciaEscucha(String uid) {
    _uid = uid;
    _sub?.cancel();
    _sub = _fs.m_selectSuscripcion(uid).listen((datos) {
      suscripcion = datos;
      notifyListeners();
    }, onError: (_) {});
  }

  void m_detiene() {
    _sub?.cancel();
    _sub = null;
    suscripcion = null;
    _uid = null;
  }

  Future<ResultadoPago> m_pagar({
    required PlanModel plan,
    required String titular,
    required String numero,
    required int mes,
    required int anio,
    required String cvv,
  }) async {
    procesando = true;
    notifyListeners();

    final resultado = await _pasarela.m_procesaPago(
      montoMxn: plan.precio,
      descripcion: 'LinguaGo - Plan ${plan.nombre}',
      titular: titular,
      numero: numero,
      mes: mes,
      anio: anio,
      cvv: cvv,
    );

    if (resultado.exito) SonidosService.m_celebra();
    if (resultado.exito && _uid != null) {
      final ahora = DateTime.now();
      final fin = DateTime(ahora.year, ahora.month + plan.meses, ahora.day);
      _fs.m_guardaSuscripcion(_uid!, {
        'idPlan': plan.id,
        'nombrePlan': plan.nombre,
        'precio': plan.precio,
        'fechaInicio': ahora.toIso8601String(),
        'fechaFin': fin.toIso8601String(),
        'idTransaccion': resultado.idTransaccion,
        'ultimos4': numero.substring(numero.length - 4),
      });
    }

    procesando = false;
    notifyListeners();
    return resultado;
  }

  void m_cancela() {
    if (_uid != null) _fs.m_borraSuscripcion(_uid!);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
