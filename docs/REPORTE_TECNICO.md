# Reporte técnico – LinguaGo

**Integrantes:** _____________   **Materia:** _____________   **Fecha:** _____________

## 1. Planteamiento del proyecto
**Problemática.** Muchas personas quieren aprender inglés pero los cursos presenciales son caros, tienen horarios fijos y no dan seguimiento del avance. _(Ajusta y fundamenta con datos/fuentes.)_

**Objetivo general.** Desarrollar una app móvil multiplataforma que permita estudiar inglés por unidades, con progreso en la nube, práctica interactiva con sensores y un modelo de suscripción.

**Alcance.** Incluye: autenticación (correo, Google, GitHub), unidades y capítulos, ejercicio de vocabulario, notificaciones push, mapa de la academia y suscripción de 3 planes. No incluye: contenido de audio/gramática completo, backend propio, pagos en producción.

## 2. Arquitectura de software
- Flutter + **Provider** (estado). Carpetas: `components`, `config` (servicios Firebase/pagos), `models`, `providers`, `screens`.
- Flujo: `AuthGate` → onboarding → login → verificación de correo → `Dashboard` (Unidades, Mapa, Planes, Perfil).
- Firebase: Auth, Firestore (tiempo real), Storage, Cloud Messaging.
- Diagrama sugerido: pantallas ↔ providers ↔ servicios (`config`) ↔ Firebase.

## 3. Uso de sensores y componentes
- **Acelerómetro** (`sensors_plus`): agitar el teléfono avanza la tarjeta de vocabulario; se muestra la lectura en vivo (m/s²). En equipos sin sensor se usa botón.
- **Mapa nativo** (`flutter_map`): ubicación de la academia.
- **Widgets avanzados:** `CustomClipper`, `CustomPaint`, `TweenAnimationBuilder` (giro 3D de tarjeta).
- **Caché offline de imágenes:** `cached_network_image`.
- **Pagos:** formulario nativo con validación Luhn/fecha/CVV; Stripe modo prueba o simulado.

## 4. Proceso de desarrollo
_Describe sprints/semanas, tareas por integrante, problemas encontrados (p. ej. SHA-1 para Google, reglas de Firestore) y cómo los resolviste. Adjunta capturas y enlace al repositorio._

## 5. Conclusiones
_Aprendizajes, limitaciones (clave Stripe en cliente, contenido de ejemplo) y trabajo futuro (backend para pagos, más ejercicios, modo offline completo)._
