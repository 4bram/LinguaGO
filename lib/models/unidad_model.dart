/// Unidad de aprendizaje. El catálogo base se sincroniza con Firestore
/// al iniciar sesión para mantener el contenido compartido entre usuarios.
class UnidadModel {
  final String id;
  final int orden;
  final String nombre;
  final bool premium;
  final String imagenUrl;
  final List<String> capitulos;
  final List<Map<String, String>> vocabulario;

  UnidadModel({
    required this.id,
    required this.orden,
    required this.nombre,
    required this.premium,
    required this.capitulos,
    required this.vocabulario,
    this.imagenUrl = '',
  });

  factory UnidadModel.fromMap(String id, Map<String, dynamic> mapa) {
    return UnidadModel(
      id: id,
      orden: (mapa['orden'] as num?)?.toInt() ?? 0,
      nombre: mapa['nombre'] as String? ?? '',
      premium: mapa['premium'] as bool? ?? false,
      imagenUrl: mapa['imagenUrl'] as String? ?? '',
      capitulos: (mapa['capitulos'] as List? ?? const []).map((e) => e.toString()).toList(),
      vocabulario: (mapa['vocabulario'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString())))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    final mapa = <String, dynamic>{
      'orden': orden,
      'nombre': nombre,
      'premium': premium,
      'versionCatalogo': 2,
      'capitulos': capitulos,
      'vocabulario': vocabulario,
    };
    // No borrar una imagen personalizada que ya exista en Firestore.
    if (imagenUrl.isNotEmpty) mapa['imagenUrl'] = imagenUrl;
    return mapa;
  }

  static List<UnidadModel> iniciales() {
    UnidadModel crear(int n, String nombre, List<String> capitulos,
        String palabras, {bool premium = false}) {
      final vocab = palabras.split(';').map((par) {
        final p = par.split('|');
        return <String, String>{'en': p[0], 'es': p.length > 1 ? p[1] : ''};
      }).toList();
      return UnidadModel(
        id: 'unidad$n',
        orden: n,
        nombre: nombre,
        premium: premium,
        capitulos: capitulos,
        vocabulario: vocab,
      );
    }

    return [
      crear(1, 'Introducción', ['Saludos y despedidas', 'El abecedario', 'Números y edad', 'Presentarse', 'Países y nacionalidades', 'Frases de cortesía'],
        'Hello|Hola;Hi|Hola;Good morning|Buenos días;Good afternoon|Buenas tardes;Good evening|Buenas noches;Goodbye|Adiós;See you later|Hasta luego;Please|Por favor;Thank you|Gracias;You are welcome|De nada;Excuse me|Disculpe;Sorry|Lo siento;Name|Nombre;Surname|Apellido;Nice to meet you|Mucho gusto;How are you?|¿Cómo estás?;I am fine|Estoy bien'),
      crear(2, 'Trabajo y escuela', ['Materias escolares', 'Útiles y materiales', 'Profesiones', 'Lugares de trabajo', 'Rutina de estudio', 'Entrevistas'],
        'Teacher|Maestro;Student|Estudiante;Doctor|Doctor;Nurse|Enfermero;Engineer|Ingeniero;Designer|Diseñador;Waiter|Mesero;Lawyer|Abogado;Police officer|Policía;Firefighter|Bombero;Office|Oficina;School|Escuela;University|Universidad;Classroom|Salón;Homework|Tarea;Exam|Examen;Notebook|Cuaderno;Pencil|Lápiz;Lesson|Lección;Meeting|Reunión;Job|Empleo;Salary|Salario;Interview|Entrevista'),
      crear(3, 'Comida y bebidas', ['Frutas y verduras', 'Comidas del día', 'En el restaurante', 'Bebidas y cantidades', 'Cocinar', 'Pedir comida'],
        'Water|Agua;Bread|Pan;Apple|Manzana;Banana|Plátano;Orange|Naranja;Strawberry|Fresa;Grapes|Uvas;Carrot|Zanahoria;Potato|Papa;Tomato|Tomate;Rice|Arroz;Beans|Frijoles;Chicken|Pollo;Beef|Carne de res;Fish|Pescado;Egg|Huevo;Cheese|Queso;Milk|Leche;Coffee|Café;Tea|Té;Breakfast|Desayuno;Lunch|Comida;Dinner|Cena;Menu|Menú;Bill|Cuenta;Delicious|Delicioso'),
      crear(4, 'Lugares y direcciones', ['Lugares de la ciudad', 'Cómo pedir direcciones', 'Preposiciones de lugar', 'Transporte público', 'Indicaciones', 'Moverse por la ciudad'],
        'Street|Calle;Avenue|Avenida;Corner|Esquina;Traffic light|Semáforo;Crosswalk|Cruce peatonal;Bridge|Puente;Square|Plaza;Park|Parque;Museum|Museo;Hospital|Hospital;Pharmacy|Farmacia;Bank|Banco;Library|Biblioteca;Post office|Oficina postal;Bus stop|Parada de autobús;Train station|Estación de tren;Airport|Aeropuerto;Turn left|Gira a la izquierda;Turn right|Gira a la derecha;Go straight|Sigue derecho;Nearby|Cerca;Far|Lejos', premium: true),
      crear(5, 'Estilo de vida', ['Rutina diaria', 'Pasatiempos', 'Hábitos saludables', 'Deporte y descanso', 'Planes de fin de semana', 'Mi estilo de vida'],
        'Wake up|Despertarse;Get up|Levantarse;Take a shower|Ducharse;Get dressed|Vestirse;Have breakfast|Desayunar;Go to work|Ir al trabajo;Study|Estudiar;Have lunch|Comer;Come home|Volver a casa;Cook|Cocinar;Exercise|Hacer ejercicio;Relax|Relajarse;Go to bed|Acostarse;Always|Siempre;Usually|Usualmente;Often|A menudo;Sometimes|A veces;Rarely|Rara vez;Never|Nunca;Early|Temprano;Late|Tarde;At noon|Al mediodía;At midnight|A medianoche;Hobby|Pasatiempo;Reading|Lectura;Drawing|Dibujar;Painting|Pintar;Singing|Cantar;Dancing|Bailar;Swimming|Nadar;Running|Correr;Cycling|Andar en bicicleta;Hiking|Senderismo;Photography|Fotografía;Gardening|Jardinería;Gaming|Videojuegos;Movie|Película;Concert|Concierto;Free time|Tiempo libre;Enjoy|Disfrutar;Prefer|Preferir;Love|Encantar;Hate|Odiar;Join us|Únete a nosotros', premium: true),
      crear(6, 'Personas y familia', ['La familia', 'Describir personas', 'Apariencia física', 'Personalidad', 'Relaciones', 'Mi árbol familiar'],
        'Mother|Madre;Father|Padre;Parents|Padres;Sister|Hermana;Brother|Hermano;Daughter|Hija;Son|Hijo;Grandmother|Abuela;Grandfather|Abuelo;Cousin|Primo;Aunt|Tía;Uncle|Tío;Husband|Esposo;Wife|Esposa;Tall|Alto;Short|Bajo;Kind|Amable;Funny|Divertido;Shy|Tímido;Friendly|Amigable'),
      crear(7, 'Casa y vida diaria', ['Partes de la casa', 'Muebles', 'Objetos cotidianos', 'Tareas domésticas', 'Mi habitación', 'Describir mi hogar'],
        'House|Casa;Apartment|Departamento;Bedroom|Dormitorio;Kitchen|Cocina;Bathroom|Baño;Living room|Sala;Garden|Jardín;Door|Puerta;Window|Ventana;Table|Mesa;Chair|Silla;Bed|Cama;Pillow|Almohada;Blanket|Cobija;Mirror|Espejo;Lamp|Lámpara;Fridge|Refrigerador;Shelf|Estante;Clean|Limpiar;Sweep|Barrer'),
      crear(8, 'Tiempo y clima', ['Días y meses', 'Las estaciones', 'El clima', 'Temperaturas', 'Hablar del pronóstico', 'Planes según el clima'],
        'Monday|Lunes;Tuesday|Martes;Wednesday|Miércoles;Thursday|Jueves;Friday|Viernes;Saturday|Sábado;Sunday|Domingo;January|Enero;February|Febrero;March|Marzo;April|Abril;May|Mayo;June|Junio;July|Julio;August|Agosto;September|Septiembre;October|Octubre;November|Noviembre;December|Diciembre;Sunny|Soleado;Cloudy|Nublado;Rainy|Lluvioso;Windy|Ventoso;Storm|Tormenta;Weather|Clima;Warm|Templado;Cold|Frío'),
      crear(9, 'Compras y dinero', ['Tiendas y productos', 'Ropa y tallas', 'Precios y dinero', 'Formas de pago', 'Comparar productos', 'Devoluciones'],
        'Shop|Tienda;Store|Comercio;Market|Mercado;Price|Precio;Cheap|Barato;Expensive|Caro;Discount|Descuento;Receipt|Recibo;Cash|Efectivo;Credit card|Tarjeta de crédito;Wallet|Cartera;Change|Cambio;Size|Talla;Small|Chico;Medium|Mediano;Large|Grande;Try on|Probarse;Fit|Quedar;Sale|Rebaja;Refund|Reembolso;Exchange|Cambio;How much is it?|¿Cuánto cuesta?'),
      crear(10, 'Viajes y vacaciones', ['Preparar un viaje', 'En el aeropuerto', 'Hotel y hospedaje', 'Equipaje', 'Turismo', 'Resolver imprevistos'],
        'Trip|Viaje;Travel|Viajar;Ticket|Boleto;Passport|Pasaporte;Visa|Visa;Luggage|Equipaje;Suitcase|Maleta;Boarding pass|Pase de abordar;Flight|Vuelo;Gate|Puerta de embarque;Departure|Salida;Arrival|Llegada;Reservation|Reservación;Hotel|Hotel;Reception|Recepción;Single room|Habitación individual;Double room|Habitación doble;Key|Llave;Tour|Recorrido;Guide|Guía;Souvenir|Recuerdo;Lost|Perdido;Delayed|Retrasado'),
      crear(11, 'Salud y bienestar', ['Partes del cuerpo', 'Síntomas comunes', 'En el médico', 'Hábitos saludables', 'Ejercicio y descanso', 'Dar recomendaciones'],
        'Head|Cabeza;Neck|Cuello;Shoulder|Hombro;Arm|Brazo;Hand|Mano;Finger|Dedo;Back|Espalda;Leg|Pierna;Knee|Rodilla;Foot|Pie;Stomach|Estómago;Headache|Dolor de cabeza;Fever|Fiebre;Cough|Tos;Cold|Resfriado;Pain|Dolor;Medicine|Medicina;Appointment|Cita;Healthy|Saludable;Tired|Cansado;Rest|Descansar;Drink water|Beber agua'),
      crear(12, 'Tecnología y comunicación', ['Dispositivos', 'Internet', 'Aplicaciones', 'Mensajes y llamadas', 'Problemas técnicos', 'Seguridad digital'],
        'Computer|Computadora;Laptop|Portátil;Keyboard|Teclado;Screen|Pantalla;Mouse|Ratón;Headphones|Audífonos;Charger|Cargador;Battery|Batería;Password|Contraseña;Username|Usuario;Website|Sitio web;Download|Descargar;Upload|Subir;Update|Actualizar;File|Archivo;Folder|Carpeta;Message|Mensaje;Call|Llamada;Attachment|Adjunto;Connection|Conexión;Settings|Configuración;Privacy|Privacidad'),
      crear(13, 'Naturaleza y animales', ['Animales domésticos', 'Animales salvajes', 'Paisajes', 'Plantas y árboles', 'Medio ambiente', 'Cuidar el planeta'],
        'Dog|Perro;Cat|Gato;Bird|Pájaro;Horse|Caballo;Rabbit|Conejo;Cow|Vaca;Sheep|Oveja;Fox|Zorro;Bear|Oso;Wolf|Lobo;Deer|Ciervo;Eagle|Águila;Forest|Bosque;Mountain|Montaña;River|Río;Lake|Lago;Ocean|Océano;Beach|Playa;Tree|Árbol;Flower|Flor;Environment|Medio ambiente;Recycle|Reciclar;Pollution|Contaminación'),
      crear(14, 'Emociones y opiniones', ['Emociones básicas', 'Estados de ánimo', 'Expresar opiniones', 'Estar de acuerdo', 'Describir experiencias', 'Conversaciones reales'],
        'Happy|Feliz;Sad|Triste;Angry|Enojado;Worried|Preocupado;Excited|Emocionado;Nervous|Nervioso;Surprised|Sorprendido;Bored|Aburrido;Relaxed|Relajado;Proud|Orgulloso;Afraid|Asustado;Confident|Seguro;I think|Pienso que;I believe|Creo que;In my opinion|En mi opinión;I agree|Estoy de acuerdo;I disagree|No estoy de acuerdo;Maybe|Quizá;Probably|Probablemente;It depends|Depende'),
      crear(15, 'Gramática esencial', ['Presente simple', 'Presente continuo', 'Pasado simple', 'Futuro con going to', 'Artículos y plurales', 'Pronombres y posesivos'],
        'Usually|Usualmente;Right now|Ahora mismo;Yesterday|Ayer;Last week|La semana pasada;Tomorrow|Mañana;Next month|El próximo mes;Already|Ya;Yet|Todavía;Before|Antes;After|Después;Every day|Todos los días;At the moment|En este momento;Was|Era/estaba;Were|Eran/estaban;Did|Auxiliar pasado;Does|Auxiliar tercera persona;Do|Auxiliar presente;Will|Futuro;Going to|Ir a;Their|De ellos;Our|Nuestro;Mine|Mío'),
      crear(16, 'Inglés para el trabajo', ['Comunicación profesional', 'Correos electrónicos', 'Reuniones', 'Proyectos y tareas', 'Atención al cliente', 'Negociación básica'],
        'Deadline|Fecha límite;Schedule|Horario;Task|Tarea;Project|Proyecto;Team|Equipo;Colleague|Colega;Manager|Gerente;Client|Cliente;Customer|Consumidor;Feedback|Comentarios;Report|Informe;Invoice|Factura;Email|Correo;Attachment|Archivo adjunto;Forward|Reenviar;Reply|Responder;Available|Disponible;Busy|Ocupado;Meeting room|Sala de juntas;Could you...?|¿Podrías...?;Please find attached|Adjunto encontrarás', premium: true),
      crear(17, 'Conversación intermedia', ['Small talk', 'Contar anécdotas', 'Hacer sugerencias', 'Resolver malentendidos', 'Expresiones naturales', 'Conversación telefónica'],
        'Actually|En realidad;By the way|Por cierto;I mean|Quiero decir;Sounds good|Suena bien;No worries|No te preocupes;That makes sense|Tiene sentido;What do you mean?|¿Qué quieres decir?;Let me think|Déjame pensar;As far as I know|Hasta donde sé;To be honest|Para ser sincero;It turns out|Resulta que;Long time no see|Tanto tiempo;How come?|¿Cómo es que?;Never mind|No importa;Hang on|Espera;I see|Ya veo;Fair enough|Está bien;Definitely|Definitivamente', premium: true),
      crear(18, 'Situaciones cotidianas', ['En una cafetería', 'En el banco', 'En una farmacia', 'Pedir ayuda', 'Quejas y soluciones', 'Emergencias básicas'],
        'Could I have...?|¿Me podría dar...?;I would like|Quisiera;For here|Para comer aquí;To go|Para llevar;Account|Cuenta bancaria;Cash machine|Cajero automático;Withdraw|Retirar;Deposit|Depositar;Prescription|Receta médica;Dosage|Dosis;Allergic|Alérgico;Help me|Ayúdeme;I need assistance|Necesito ayuda;It is broken|Está descompuesto;There is a problem|Hay un problema;I would like a refund|Quisiera un reembolso;Emergency|Emergencia;Fire department|Bomberos;Police station|Comisaría', premium: true),
      crear(19, 'Inglés avanzado práctico', ['Phrasal verbs frecuentes', 'Conectores', 'Expresiones idiomáticas', 'Matices y precisión', 'Argumentar ideas', 'Comprensión avanzada'],
        'Find out|Averiguar;Give up|Rendirse;Look after|Cuidar;Carry on|Continuar;Put off|Posponer;Run out of|Quedarse sin;Although|Aunque;However|Sin embargo;Therefore|Por lo tanto;Moreover|Además;Unless|A menos que;Despite|A pesar de;On the other hand|Por otro lado;Take into account|Tomar en cuenta;As a result|Como resultado;In the long run|A largo plazo;To some extent|Hasta cierto punto;It goes without saying|No hace falta decirlo', premium: true),
      crear(20, 'Números, fechas y medidas', ['Números cardinales', 'Números ordinales', 'Fechas y cumpleaños', 'Horas y duración', 'Medidas y cantidades', 'Hacer cálculos cotidianos'],
        'Zero|Cero;One|Uno;Two|Dos;Three|Tres;Four|Cuatro;Five|Cinco;Ten|Diez;Twenty|Veinte;Thirty|Treinta;Forty|Cuarenta;Fifty|Cincuenta;One hundred|Cien;One thousand|Mil;First|Primero;Second|Segundo;Third|Tercero;Fourth|Cuarto;Birthday|Cumpleaños;Date|Fecha;Year|Año;Month|Mes;Week|Semana;Hour|Hora;Minute|Minuto;Second|Segundo;Half|Mitad;Quarter|Cuarto;Kilometer|Kilómetro;Meter|Metro;Liter|Litro;Kilo|Kilo;How many?|¿Cuántos?;How much?|¿Cuánto?', premium: false),
    ];
  }
}
