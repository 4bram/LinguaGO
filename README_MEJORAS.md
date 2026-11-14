# LinguaGo – mejoras de contenido y práctica

## Qué se amplió
- Catálogo base de 20 unidades y 120 capítulos, sincronizado con Firestore.
- 462 entradas de vocabulario (618 audios únicos (incluye vocabulario complementario por capítulo)), con traducción al español.
- Búsqueda por unidad, capítulo y palabra en el catálogo.
- Actividades funcionales: tarjetas de vocabulario, escucha, gramática, escritura y evaluación.
- Ejercicios de escucha con MP3 locales opcionales y voz del sistema como respaldo.
- Capítulos desplegables con objetivo, explicación, vocabulario temático y accesos directos a sus actividades.
- Lección por capítulo con ejemplos en contexto y pronunciación de cada palabra.
- Vocabulario, escucha, escritura, gramática y evaluación filtrados por el capítulo seleccionado; ya no se mezclan listas aleatorias de toda la unidad.
- Preguntas de gramática contextuales al tema del capítulo, en lugar de reutilizar el banco global. La evaluación final mezcla vocabulario y gramática del mismo capítulo.
- Progreso registrado en el capítulo que realmente se practicó; las evaluaciones requieren al menos 70% para sumar avance.
- Migración del catálogo a versión 2: las unidades antiguas reciben el contenido nuevo una sola vez; las imágenes personalizadas se conservan.

## Coherencia pedagógica de capítulos
Cada capítulo usa una selección temática de vocabulario de su unidad. Si la unidad no contiene palabras suficientes para un subtema, se agregan términos base específicos del capítulo en lugar de tomar palabras aleatorias de otros temas. Las lecciones muestran objetivo, explicación y ejemplos antes de practicar.

## Instalar las dependencias
Desde la carpeta del proyecto:

```bash
flutter pub get
flutter analyze
flutter run
```

## Audios
Consulta `README_AUDIOS.md` y `AUDIO_GUIA.csv`. Los MP3 se colocan en `assets/audios/`. No es obligatorio descargarlos: la escucha usa TTS del dispositivo si no existe un archivo local.

## Nota sobre pagos
El pago está expresamente en modo demostración y no realiza cargos reales. No pongas una clave secreta de Stripe dentro de Flutter. Para cobros reales se necesita un backend seguro y Stripe PaymentSheet.

## Firebase
El catálogo se sincroniza cuando el usuario inicia sesión y se abre el flujo de unidades. La sincronización actualiza el catálogo base a versión 2 sin borrar `imagenUrl` si la unidad ya tiene una imagen personalizada.

## Estructura de plataformas
El ZIP que recibí contiene el código Dart y `pubspec.yaml`, pero no incluye las carpetas nativas `android/` ni `ios/`. Si tu copia local tampoco las tiene, desde `nuevo/` ejecuta una sola vez:

```bash
flutter create --platforms=android,ios .
flutter pub get
```

Si tu proyecto local ya tiene `android/` e `ios/`, conserva esas carpetas y copia únicamente los archivos actualizados. No ejecutes `flutter create` encima de una configuración nativa que ya funcione.

## Corrección de coherencia entre capítulos
- Cada capítulo se abre como una lección real con objetivo, explicación, vocabulario del tema, ejemplos bilingües y pronunciación.
- Las actividades reciben `unidadId` + `capituloIndex`, de modo que escucha, escritura, gramática, evaluación y tarjetas trabajan sobre el mismo capítulo.
- Se eliminó el uso del banco global de gramática en las prácticas de capítulo. Las preguntas se generan por el tema; las prácticas generales de unidad conservan su banco general.
- Si un capítulo no tiene vocabulario suficiente en el catálogo guardado, utiliza un pequeño conjunto temático propio; nunca rellena con palabras aleatorias de otra temática.
- El avance se guarda en el capítulo que se practicó. Las evaluaciones de capítulo requieren 70% de aciertos; una sesión de tarjetas aporta avance al capítulo correspondiente.
