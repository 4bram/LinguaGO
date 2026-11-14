# Seguridad y pagos

- La clave secreta de Stripe nunca debe guardarse en `.env` dentro de Flutter: los archivos incluidos en una app pueden extraerse.
- El flujo de pago de este proyecto queda en **modo demostración local**: valida el formulario y activa el plan de prueba en Firebase, pero no cobra dinero.
- Para aceptar pagos reales se necesita un backend HTTPS (por ejemplo Cloud Functions) que cree el PaymentIntent con la clave secreta y Stripe PaymentSheet en la app. No habilites cobros reales desde el cliente.
- El archivo `.env` es opcional para iniciar la app. Si faltan variables, las integraciones que las necesiten deben mostrar un estado de configuración y no bloquear el resto de LinguaGo.
