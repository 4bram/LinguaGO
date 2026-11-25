# Recorrido guiado (introducción guiada de las funciones principales)

Cumple el punto de la guía: *"Onboarding: secuencia de pantallas de bienvenida e introducción
guiada para presentar las funciones principales de la aplicación"*.

- **Bienvenida:** las 4 pantallas de `onboarding_screen.dart` (como antes).
- **Introducción guiada (NUEVO):** un recorrido de 8 pasos sobre la app real. Una capa oscura
  resalta cada función (botón de Unidades, buscador, tarjeta de unidad, Mapa, Planes, Perfil) y una
  tarjeta explica qué hace, con botones ATRÁS / SIGUIENTE / SALTAR. Cambia de pestaña solo.

## Cuándo aparece
- La primera vez que cada usuario entra al dashboard (se recuerda por usuario, en el teléfono y en
  Firestore: `usuarios/{uid}/preferencias/guiaVista`).
- Cuando quieras repetirlo: **Perfil → Recorrido guiado**.
- El botón "atrás" del teléfono lo salta.

## Archivos
| Archivo | Qué hace |
|---|---|
| `lib/providers/guia_provider.dart` | Estado del recorrido (Provider, sin setState) |
| `lib/components/guia_overlay.dart` | Capa oscura con hueco (CustomPaint), tarjeta y pasos |
| `lib/screens/dashboard_screen.dart` | Coloca la capa encima de la app y le da las llaves de la barra |
| `lib/screens/unidades_screen.dart` | Llaves del buscador y de la primera unidad |
| `lib/screens/perfil_screen.dart` | Opción "Recorrido guiado" |

## Cambiar los textos o pasos
Están en la lista `_pasos` de `guia_overlay.dart`.
