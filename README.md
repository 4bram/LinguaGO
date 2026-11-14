# LinguaGo – Proyecto final (Flutter + Firebase)

App para aprender inglés en línea. Diseño basado en la referencia morada
(portada, unidades principales y detalle de unidad). Estructura de carpetas y
estilo de código tomados del proyecto de clase (`components / config / models / screens`,
métodos con prefijo `m_`).

## 1. Cómo correrla (paso a paso)

### Requisitos
- Flutter instalado (`flutter doctor` sin errores) y Android Studio / un celular Android.
- Node.js (para Firebase CLI) y una cuenta de Google.

### Pasos
```bash
# 1) Descomprime el ZIP y entra a la carpeta
cd lingua_go

# 2) Genera las carpetas de plataforma (android, ios, web...) SIN tocar tu código
flutter create --project-name lingua_go --org mx.edu.tuescuela .

# 3) Instala dependencias
flutter pub get

# 4) Conecta Firebase (genera lib/firebase_options.dart y google-services.json)
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login
flutterfire configure        # elige/crea tu proyecto y marca Android (y Web si quieres)

# 5) Ejecuta
flutter run                  # celular o emulador Android
flutter run -d chrome        # para ver el diseño de ESCRITORIO / responsivo
```

### Ajustes de Android (después del paso 2)
1. `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` (antes de `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
2. `android/app/build.gradle(.kts)`: asegúrate de `minSdk = 23` (o mayor).
3. Si al compilar falta el plugin de Google Services, `flutterfire configure` normalmente lo agrega;
   si no, sigue la guía oficial: https://firebase.google.com/docs/flutter/setup

## 2. Configuración en la consola de Firebase

| Servicio | Qué hacer |
|---|---|
| Authentication → Sign-in method | Habilitar **Correo/contraseña**, **Google** y **GitHub** |
| Google en Android | Agregar la huella **SHA-1**: `cd android && ./gradlew signingReport` y pegarla en Configuración del proyecto → tu app Android; volver a correr `flutterfire configure` |
| GitHub | En github.com → Settings → Developer settings → OAuth Apps: crear app con la *callback URL* que muestra Firebase; pegar Client ID y Secret en Firebase |
| Firestore Database | Crear base de datos y pegar las reglas de abajo |
| Imágenes (Supabase Storage) | Ver sección "Imágenes con Supabase" más abajo (no requiere tarjeta) |
| Cloud Messaging | Sin código backend: **Engage → Messaging → Nueva campaña → Notificación**. Para probar temas: Destino = *Tema* (`general`, `ofertas`, `nuevas_unidades`, `recordatorios`) |

**Reglas de seguridad**: están en `firestore.rules` (raíz del proyecto).
Pégalas en Firebase Console → Firestore → Reglas (o `firebase deploy --only firestore:rules`).
- `unidades`: lectura con sesión; cualquier usuario puede crear una unidad que no existe (siembra inicial), pero **solo un administrador** puede modificarlas; no se pueden borrar.
- `usuarios/{uid}`: solo el dueño; `pedidos` solo se crean y leen (no se editan ni borran).

**Administradores:** en Firestore crea la colección `admins` y un documento cuyo **ID sea el uid** del usuario (Authentication → Usuarios → UID; cualquier campo, p. ej. `rol: "admin"`). Solo esos usuarios ven el botón de cámara en la unidad. Si el catálogo necesita migrarse a una versión nueva, abre la app una vez con una cuenta admin.

Las unidades se **siembran solas** en Firestore la primera vez que entras a la app.

## 2b. Imágenes con Supabase Storage (en lugar de Firebase Storage)
Firebase Storage exige tarjeta, así que las imágenes (foto de perfil e imagen de unidad) se guardan en Supabase (plan gratuito, sin tarjeta). Todo lo demás sigue en Firebase.
1. Crea un proyecto en supabase.com.
2. **Storage → New bucket**: nombre `imagenes`, **Public bucket = activado**, *File size limit* = `5 MB`, *Allowed MIME types* = `image/*`.
3. **SQL Editor** → ejecuta:
   ```sql
   create policy "subir imagenes"
   on storage.objects for insert
   to anon, authenticated
   with check (bucket_id = 'imagenes');
   ```
   (Solo permite SUBIR; no hay política de editar ni borrar, así que nadie puede sobrescribir archivos existentes. Leer las imágenes no necesita política porque el bucket es público.)
4. **Project Settings → API**: copia la *Project URL* y la clave *anon / publishable* y ponlas en tu `.env`:
   ```
   SUPABASE_URL=https://xxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=tu_clave
   ```
5. **Segundo bucket `recursos`** (contenido de la tienda): **New bucket** → nombre `recursos`, **Public bucket = activado**, sin restricción de MIME (para permitir PDF). NO crees política de insertar: solo tú subes archivos desde el panel. Prepara tus archivos reales con `bash supabase_recursos/preparar_archivos.sh <tu carpeta de recursos>` (los copia con el nombre que espera la app a `supabase_recursos/archivos/`). Luego, en el bucket, sube las carpetas **`archivos/`** y **`portadas/`** de `supabase_recursos/` para que queden las rutas `archivos/<id>.<pdf|xlsx|docx>` y `portadas/<id>.png`.
6. Detén la app y vuelve a correr `flutter run` (el `.env` no se relee con hot reload).

**Qué guarda cada bucket**
| Bucket | Contenido | Quién escribe |
|---|---|---|
| `imagenes` | `perfiles/<uid>/…jpg` (foto de perfil), `unidades/<id>/…jpg` (solo admin), `certificados/<uid>/…png` (certificado de cada unidad aprobada) | la app |
| `recursos` | `archivos/<producto>.pdf/.xlsx/.docx` (descarga de lo comprado), `portadas/<producto>.png` (portada de la tienda) | el administrador (panel de Supabase) |

⚠️ Supabase no conoce a los usuarios de Firebase, así que ya no se puede limitar por servidor quién sube cada imagen. Lo que sí se mantiene: solo los administradores ven el botón de cambiar imagen de unidad, y solo ellos pueden guardar la URL en Firestore (reglas); además el bucket limita tamaño y tipo de archivo.

## 3. Pagos (Stripe, modo prueba) y tienda
- **Suscripciones** (3 planes) y **tienda de productos** (carrito + checkout) usan la misma pasarela: `config/pasarela_pago.dart`.
- Flujo con Stripe: pantalla nativa captura y valida la tarjeta (Luhn, fecha, CVV) → se crea un *PaymentMethod* → se crea y confirma un *PaymentIntent* (MXN). Solo si Stripe devuelve `succeeded` se activa la suscripción o se guarda el pedido en `usuarios/{uid}/pedidos`.
- Para activarlo: copia `.env.example` a `.env` y pon tu clave de **prueba** (`STRIPE_SECRET_KEY=sk_test_...`, Dashboard en modo prueba → Developers → API keys). Una clave `sk_live_` se rechaza.
- Tarjeta buena: `4242 4242 4242 4242` · rechazo: `4000 0000 0000 0002` · cualquier fecha futura y CVV.
- Si Stripe responde que bloquea datos de tarjeta, en el Dashboard (modo prueba) activa **Developers → Settings → Raw card data APIs**.
- Sin clave, la app funciona en **modo demostración local** (sin llamar a Stripe).
- ⚠️ Una clave secreta dentro de una app móvil puede extraerse: es válido SOLO para la entrega académica en modo prueba. En producción, el PaymentIntent debe crearlo un backend (p. ej. Cloud Function) y la app usar Stripe PaymentSheet.
- **No subas `.env` con tu clave a GitHub** (agrégalo a `.gitignore`; el repositorio conserva `.env.example`).

### Qué recibe el usuario al comprar
Los productos son contenido digital real (15 productos en `models/producto_model.dart`): los 10 recursos del equipo (archivos PDF/XLSX/DOCX que se descargan del bucket) más 5 extras con PDF incluido. Varios traen además una *vista rápida* dentro de la app que funciona sin internet.
- Al pagar, el pedido se guarda en `usuarios/{uid}/pedidos` y el producto aparece en **Tienda → Mi biblioteca** (también contador en Perfil).
- Se abre en `contenido_producto_screen.dart`: búsqueda, lectura en voz alta (TTS), tarjetas que se voltean y botones de **descarga** por formato (del bucket `recursos`, con `url_launcher`).
- Un producto digital solo se compra una vez (queda como «Comprado · Abrir»).
- Android 11+: para abrir enlaces/llamadas agrega en `AndroidManifest.xml`, dentro de `<manifest>`:
  ```xml
  <queries>
    <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
    <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
  </queries>
  ```

## 3a. Sonidos de la interfaz (locales, sin internet)
Copia tus MP3 a `assets/sonidos/` con estos nombres: `presionar.mp3`, `burbuja.mp3`, `burbuja2soft.mp3`, `bell.mp3`, `bell2.mp3`, `transicion.mp3` (van dentro del APK). Suenan al tocar botones principales, agregar/quitar del carrito, voltear tarjetas, cambiar de pestaña, aprobar evaluaciones y pagar. Se apagan en Perfil → «Sonidos de la app». Si falta un archivo, simplemente no suena. Después de copiarlos: `flutter clean` y `flutter run`.

## 3b. Progreso, evaluaciones y certificados
- Un capítulo llega a **100 %** solo cuando completas TODAS sus actividades (lección, tarjetas, escucha, gramática, escritura) **y** apruebas su evaluación con **≥ 70 %**. Antes de eso el avance es parcial.
- Cada evaluación guarda en Firestore (`usuarios/{uid}/progreso`) mejor resultado, último resultado, intentos y fecha.
- Al aprobar un capítulo se desbloquea el siguiente; al aprobar la **evaluación final** de la unidad (≥ 70 %) se desbloquea la unidad siguiente y se genera un **certificado PNG** que se guarda en Supabase (`imagenes/certificados/…`). Se consultan en Perfil → **Mis certificados**.
- Los administradores no tienen bloqueos de unidad (para revisar contenido).
- Si ya tenías progreso guardado con la versión anterior (campo `capitulos`), se ignora y se empieza de cero.
- **Modo oscuro por usuario**: se guarda en Firestore y localmente por `uid`; al cambiar de cuenta se carga el tema de esa cuenta.
- **Mapa**: 3 sedes (datos de ejemplo editables en `models/sede_model.dart`), selector de sede, «Abierto ahora» calculado con el horario, **Cómo llegar** (app de mapas) y **Llamar**.

## 4. Cumplimiento de la guía del proyecto

| Requisito | Dónde está |
|---|---|
| Storage (imágenes) | `config/storage_service.dart` (Supabase Storage: foto de perfil, imágenes de unidad, certificados y PDF/portadas de la tienda) |
| Firebase Database (tiempo real) | Cloud Firestore con `snapshots()`: `config/firestore_unidades.dart`, `firestore_usuario.dart` |
| FCM: consola, listener global, topics, 3 estados | `config/notificaciones_service.dart`, `providers/notificaciones_provider.dart`, `screens/notificaciones_screen.dart`, `main.dart` |
| Auth: 2 proveedores + correo | `config/social_auth.dart` (Google, GitHub), `config/email_auth.dart` |
| Verificación de correo, reenvío, recuperación | `screens/verificar_correo_screen.dart`, `recuperar_password_screen.dart` |
| Perfil, foto sincronizada, edición solo correo | `screens/perfil_screen.dart`, `components/avatar_usuario.dart`, `sesion_provider.dart` |
| Estado con Provider (sin setState/ValueNotifier) | carpeta `providers/` (incluye `busqueda_provider.dart` y `practica_provider.dart`) |
| Fuente personalizada + tema claro/oscuro | `components/theme_app.dart` (Raleway), `preferencias_provider.dart` |
| Onboarding | `screens/onboarding_screen.dart` |
| Responsivo móvil/escritorio | `components/responsive.dart`, `dashboard_screen.dart` (NavigationRail), grids adaptativos |
| Widget avanzado (10 %) | `ClipPath/CustomClipper` (`curva_clipper.dart`), `CustomPaint` (`anillo_progreso.dart`), `TweenAnimationBuilder` 3D (`flashcards_screen.dart`) |
| Caché de imágenes offline | `cached_network_image` (avatar, imágenes de unidades) |
| Sensor | Acelerómetro: agitar para pasar tarjeta (`flashcards_provider.dart`) |
| Mapa nativo | `screens/mapa_screen.dart` (flutter_map, sin WebView; varias sedes, abierto ahora, cómo llegar) |
| Pagos / suscripciones (15 %) | Stripe (modo prueba) en `config/pasarela_pago.dart`; 3 planes en `models/plan_model.dart` y `pago_screen.dart`; tienda con carrito en `tienda_screen.dart`, `carrito_screen.dart`, `providers/carrito_provider.dart` |
| Reporte técnico | `docs/REPORTE_TECNICO.md` (plantilla) |

## 5. Notas
- Unidades 4 y 5 son **premium** (se desbloquean con un plan).
- Para cambiar la imagen de una unidad: botón de cámara en el encabezado (solo administradores; sube a Storage).
- Los commits en GitHub se evalúan: haz commits frecuentes y pequeños, cada integrante con su usuario.
