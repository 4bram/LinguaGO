import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingua_go/components/global_values.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/firebase_options.dart';
import 'package:lingua_go/models/notificacion_model.dart';
import 'package:lingua_go/providers/notificaciones_provider.dart';

/// Handler para mensajes con la app en SEGUNDO PLANO o CERRADA.
/// Debe ser una función de nivel superior. Si el mensaje trae "notification"
/// (consola de Firebase), el sistema operativo la muestra solo.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Cloud Messaging administrado desde la consola de Firebase (sin backend).
class NotificacionesService {
  /// FCM solo se usa en Android / iOS.
  static bool get soportado =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> m_suscribe(String tema) async {
    if (!soportado) return;
    await FirebaseMessaging.instance.subscribeToTopic(tema);
  }

  Future<void> m_desuscribe(String tema) async {
    if (!soportado) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic(tema);
  }

  /// Listener GLOBAL: se registra una sola vez al iniciar la app y por eso
  /// funciona en todas las pantallas.
  Future<void> m_inicializa({required NotificacionesProvider provider}) async {
    if (!soportado) return;
    final fcm = FirebaseMessaging.instance;

    try {
      await fcm.requestPermission(alert: true, badge: true, sound: true);
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('FCM permisos: $e');
    }

    try {
      provider.m_guardaToken(await fcm.getToken());
      fcm.onTokenRefresh.listen((t) => provider.m_guardaToken(t));
    } catch (e) {
      debugPrint('FCM token: $e');
    }

    for (final tema in provider.temasActivos.toList()) {
      try {
        await fcm.subscribeToTopic(tema);
      } catch (e) {
        debugPrint('FCM tema $tema: $e');
      }
    }

    // 1) PRIMER PLANO
    FirebaseMessaging.onMessage.listen((mensaje) {
      final n = _convierte(mensaje, 'Primer plano');
      provider.m_agrega(n);
      _muestraBanner(n);
    });

    // 2) SEGUNDO PLANO (el usuario toca la notificación)
    FirebaseMessaging.onMessageOpenedApp.listen((mensaje) {
      final n = _convierte(mensaje, 'Segundo plano');
      provider.m_agrega(n);
      _muestraDialogo(n);
    });

    // 3) APP CERRADA (se abrió tocando la notificación)
    try {
      final inicial = await fcm.getInitialMessage();
      if (inicial != null) {
        final n = _convierte(inicial, 'App cerrada');
        provider.m_agrega(n);
        Future.delayed(const Duration(seconds: 2), () => _muestraDialogo(n));
      }
    } catch (e) {
      debugPrint('FCM inicial: $e');
    }
  }

  NotificacionModel _convierte(RemoteMessage m, String estado) {
    return NotificacionModel(
      titulo: m.notification?.title ?? m.data['titulo'] ?? 'Notificación',
      cuerpo: m.notification?.body ?? m.data['cuerpo'] ?? '',
      estado: estado,
    );
  }

  void _muestraBanner(NotificacionModel n) {
    final messenger = GlobalValues.messengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeApp.morado,
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              n.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(n.cuerpo, style: const TextStyle(color: Colors.white)),
          ],
        ),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () => _muestraDialogo(n),
        ),
      ),
    );
  }

  void _muestraDialogo(NotificacionModel n) {
    final contexto = GlobalValues.navigatorKey.currentState?.overlay?.context;
    if (contexto == null) return;
    showDialog(
      context: contexto,
      builder: (c) => AlertDialog(
        title: Text(n.titulo),
        content: Text('${n.cuerpo}\n\nRecibida con la app en: ${n.estado}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
