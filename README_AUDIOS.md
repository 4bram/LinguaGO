# Audios opcionales de LinguaGo

Los ejercicios de escucha ya funcionan sin descargar nada: si falta un MP3, LinguaGo usa la voz inglesa instalada en el dispositivo mediante `flutter_tts`.

Si quieres usar grabaciones humanas:
1. Guarda cada archivo MP3 en `assets/audios/`.
2. Usa exactamente el nombre indicado en `AUDIO_GUIA.csv`.
3. Cada archivo debe contener únicamente la pronunciación en inglés de la frase de su fila, sin traducción ni música.
4. Recomendado: voz clara en inglés estadounidense o británico, velocidad natural, mono o estéreo, 44.1 kHz. Evita silencios largos al principio y al final.
5. Ejecuta `flutter pub get` y vuelve a compilar la app para incluir los archivos.

Ejemplos:
- `hello.mp3` debe decir “Hello”.
- `good_morning.mp3` debe decir “Good morning”.
- `how_are_you.mp3` debe decir “How are you?”.

No es obligatorio descargar todos los archivos: puedes agregar solo los que tengas. Para los demás se utilizará la voz del teléfono.

La guía también incluye frases de apoyo que aparecen en capítulos cuyo vocabulario original era insuficiente. Si descargas esos MP3, el nombre del archivo sigue exactamente la columna `archivo_mp3`; la voz TTS sigue siendo la alternativa automática cuando no están disponibles.
