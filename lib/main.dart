import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lingua_go/components/global_values.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/components/toque_sonoro.dart';
import 'package:lingua_go/config/notificaciones_service.dart';
import 'package:lingua_go/config/sonidos_service.dart';
import 'package:lingua_go/firebase_options.dart';
import 'package:lingua_go/providers/busqueda_provider.dart';
import 'package:lingua_go/providers/carrito_provider.dart';
import 'package:lingua_go/providers/flashcards_provider.dart';
import 'package:lingua_go/providers/nav_provider.dart';
import 'package:lingua_go/providers/notificaciones_provider.dart';
import 'package:lingua_go/providers/preferencias_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/suscripcion_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:lingua_go/screens/auth_gate.dart';
import 'package:lingua_go/screens/carrito_screen.dart';
import 'package:lingua_go/screens/flashcards_screen.dart';
import 'package:lingua_go/screens/notificaciones_screen.dart';
import 'package:lingua_go/screens/pago_screen.dart';
import 'package:lingua_go/screens/practica_screen.dart';
import 'package:lingua_go/screens/recuperar_password_screen.dart';
import 'package:lingua_go/screens/sign_in_screen.dart';
import 'package:lingua_go/screens/tienda_screen.dart';
import 'package:lingua_go/screens/unidad_detalle_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // .env es opcional: la app puede iniciar sin claves privadas ni archivo local.
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Archivo .env no encontrado; se usarán valores por defecto: $e');
  }

  // Sonidos: lee el último valor guardado y configura el audio
  await SonidosService.m_inicializa();

  // Handler de notificaciones en segundo plano / app cerrada
  if (NotificacionesService.soportado) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final notificaciones = NotificacionesProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreferenciasProvider()),
        ChangeNotifierProvider(create: (_) => SesionProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => UnidadesProvider()),
        ChangeNotifierProvider(create: (_) => SuscripcionProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardsProvider()),
        ChangeNotifierProvider(create: (_) => BusquedaProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider.value(value: notificaciones),
      ],
      child: const MyApp(),
    ),
  );

  // Listener GLOBAL de FCM (activo en todas las pantallas)
  notificaciones.m_inicializa();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferenciasProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LinguaGo',
      navigatorKey: GlobalValues.navigatorKey,
      scaffoldMessengerKey: GlobalValues.messengerKey,
      // Sonido al abrir y cerrar pantallas, hojas y diálogos
      navigatorObservers: [SonidoObserver()],
      // Sonido de toque en toda la app
      builder: (context, child) => ToqueSonoro(child: child ?? const SizedBox.shrink()),
      theme: ThemeApp.claro(),
      darkTheme: ThemeApp.oscuro(),
      themeMode: pref.modo,
      home: const AuthGate(),
      routes: {
        '/signIn': (context) => const SignIn(),
        '/recuperar': (context) => const RecuperarPasswordScreen(),
        '/unidad': (context) => const UnidadDetalleScreen(),
        '/flashcards': (context) => const FlashcardsScreen(),
        '/practica': (context) => const PracticaScreen(),
        '/pago': (context) => const PagoScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/tienda': (context) => const TiendaScreen(),
        '/carrito': (context) => const CarritoScreen(),
      },
    );
  }
}
