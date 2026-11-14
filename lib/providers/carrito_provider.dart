import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/pasarela_pago.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/models/producto_model.dart';

/// Carrito de la tienda, pago con Stripe e historial de pedidos.
class CarritoProvider extends ChangeNotifier {
  final FirestoreUsuario _fs = FirestoreUsuario();
  final PasarelaPago _pasarela = PasarelaPago();

  final Map<String, int> _cantidades = {};
  List<Map<String, dynamic>> pedidos = [];
  bool procesando = false;
  String? categoriaFiltro; // null = todas
  String? _uid;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  bool get modoSimulado => _pasarela.modoSimulado;

  int cantidadDe(String id) => _cantidades[id] ?? 0;

  int get totalArticulos => _cantidades.values.fold(0, (a, b) => a + b);

  List<MapEntry<ProductoModel, int>> get lineas {
    final lista = <MapEntry<ProductoModel, int>>[];
    for (final p in ProductoModel.catalogo) {
      final c = cantidadDe(p.id);
      if (c > 0) lista.add(MapEntry(p, c));
    }
    return lista;
  }

  int get total => lineas.fold(0, (s, l) => s + l.key.precio * l.value);

  /// IDs de los productos ya comprados (derivados de los pedidos pagados).
  Set<String> get compradosIds {
    final r = <String>{};
    for (final pedido in pedidos) {
      for (final a in (pedido['articulos'] as List? ?? const [])) {
        if (a is Map && a['id'] != null) r.add('${a['id']}');
      }
    }
    return r;
  }

  void m_filtraCategoria(String? c) {
    categoriaFiltro = c;
    notifyListeners();
  }

  List<ProductoModel> get catalogoFiltrado => [
        for (final p in ProductoModel.catalogo)
          if (categoriaFiltro == null || p.categoria == categoriaFiltro) p,
      ];

  bool m_loTiene(String id) => compradosIds.contains(id);

  /// Productos comprados, en el orden del catálogo (Mi biblioteca).
  List<ProductoModel> get biblioteca {
    final ids = compradosIds;
    return [for (final p in ProductoModel.catalogo) if (ids.contains(p.id)) p];
  }

  void m_agrega(String id) {
    // Un contenido digital se compra una sola vez.
    if (m_loTiene(id) || cantidadDe(id) >= 1) return;
    _cantidades[id] = 1;
    SonidosService.m_burbuja();
    notifyListeners();
  }

  void m_quita(String id) {
    SonidosService.m_burbujaSuave();
    final c = cantidadDe(id);
    if (c <= 1) {
      _cantidades.remove(id);
    } else {
      _cantidades[id] = c - 1;
    }
    notifyListeners();
  }

  void m_elimina(String id) {
    _cantidades.remove(id);
    notifyListeners();
  }

  void m_iniciaEscucha(String uid) {
    _uid = uid;
    _sub?.cancel();
    _sub = _fs.m_selectPedidos(uid).listen((lista) {
      pedidos = lista;
      notifyListeners();
    }, onError: (_) {});
  }

  /// Se llama al salir del dashboard (cierre de sesión). No notifica.
  void m_detiene() {
    _sub?.cancel();
    _sub = null;
    pedidos = [];
    _cantidades.clear();
    _uid = null;
  }

  Future<ResultadoPago> m_pagar({
    required String titular,
    required String numero,
    required int mes,
    required int anio,
    required String cvv,
  }) async {
    final items = lineas;
    if (items.isEmpty) {
      return const ResultadoPago(exito: false, mensaje: 'Tu carrito está vacío.');
    }
    final monto = total;
    procesando = true;
    notifyListeners();

    final resultado = await _pasarela.m_procesaPago(
      montoMxn: monto,
      descripcion: 'LinguaGo - Tienda ($totalArticulos artículos)',
      titular: titular,
      numero: numero,
      mes: mes,
      anio: anio,
      cvv: cvv,
      metadata: {'tipo': 'tienda', 'uid': ?_uid},
    );

    if (resultado.exito) {
      if (_uid != null) {
        await _fs.m_guardaPedido(_uid!, {
          'fecha': DateTime.now().toIso8601String(),
          'total': monto,
          'estado': 'pagado',
          'idTransaccion': resultado.idTransaccion,
          'ultimos4': numero.substring(numero.length - 4),
          'articulos': [
            for (final l in items)
              {
                'id': l.key.id,
                'nombre': l.key.nombre,
                'cantidad': l.value,
                'precio': l.key.precio,
              },
          ],
        });
      }
      _cantidades.clear();
      SonidosService.m_celebra();
    }

    procesando = false;
    notifyListeners();
    return resultado;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
