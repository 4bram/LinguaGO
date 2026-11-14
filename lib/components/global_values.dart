import 'package:flutter/material.dart';

/// Llaves globales de la app.
/// Sirven para que el listener de notificaciones (FCM) pueda mostrar
/// avisos en CUALQUIER pantalla sin depender de un BuildContext.
class GlobalValues {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
