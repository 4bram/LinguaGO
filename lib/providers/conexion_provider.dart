import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConexionProvider extends ChangeNotifier {
  bool enLinea = true;
  bool comprobando = false;
  DateTime? ultima;
  Timer? _timer;

  ConexionProvider() {
    m_comprueba();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => m_comprueba());
  }

  Future<void> m_comprueba() async {
    if (comprobando) return;
    comprobando = true;
    bool ok;
    if (kIsWeb) {
      ok = true;
    } else {
      try {
        final r = await InternetAddress.lookup('example.com')
            .timeout(const Duration(seconds: 4));
        ok = r.isNotEmpty && r.first.rawAddress.isNotEmpty;
      } catch (_) {
        ok = false;
      }
    }
    comprobando = false;
    ultima = DateTime.now();
    enLinea = ok;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
