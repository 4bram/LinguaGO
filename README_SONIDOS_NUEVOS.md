# Sonidos de LinguaGo (los de la app de referencia)

## 1) Copia los archivos
Copia estos 8 archivos de `/home/nerii/RESPALDOS/audios_app/` a **`assets/sonidos/`** del proyecto
(la carpeta ya está declarada en pubspec.yaml, no hay que tocarlo):

    inicio.wav  sfx_abrir.wav  sfx_cerrar.wav  sfx_exito.wav
    sfx_guia.wav  sfx_logro.wav  sfx_portada.wav  sfx_toque.wav

Los mp3 de antes (`burbuja.mp3`, `burbuja2soft.mp3`) siguen en la misma carpeta.
Después: `flutter pub get` y vuelve a compilar.

## 2) Dónde suena cada uno
| Archivo | Cuándo |
|---|---|
| inicio.wav | Pantalla de carga al abrir la app |
| sfx_toque.wav | Cualquier toque corto en la pantalla (no al desplazar) |
| sfx_abrir.wav / sfx_cerrar.wav | Al abrir / cerrar cualquier pantalla, hoja o diálogo |
| sfx_exito.wav | Actividad completada, respuesta correcta, cuenta creada, correo enviado, evaluación final aprobada |
| sfx_logro.wav | Certificado emitido, compra exitosa, plan activado |
| sfx_portada.wav | Al abrir una unidad o un contenido de la tienda |
| sfx_guia.wav | Ambiente en bucle durante el onboarding |

## 3) Ajustar volúmenes
Están en `lib/config/sonidos_service.dart` (parámetro `volumen` de cada método) y en
`lib/screens/onboarding_screen.dart` (volumen del ambiente, 0.3).
El interruptor "Sonidos" de Perfil los apaga todos, y se guarda POR USUARIO.
