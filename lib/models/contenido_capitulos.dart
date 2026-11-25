import 'unidad_model.dart';

class ContenidoCapitulo {
  final String titulo;
  final String objetivo;
  final String explicacion;
  final List<Map<String, String>> vocabulario;
  final List<String> ejemplos;
  final List<Map<String, String>> gramatica;

  const ContenidoCapitulo({
    required this.titulo,
    required this.objetivo,
    required this.explicacion,
    required this.vocabulario,
    required this.ejemplos,
    required this.gramatica,
  });

  static String _normalizar(String s) => s.toLowerCase()
      .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
      .replaceAll('ó', 'o').replaceAll('ú', 'u');

  static const Map<String, List<String>> _temas = {
    'saludos': ['hello', 'hi', 'good morning', 'good afternoon', 'good evening', 'goodbye', 'see you later', 'how are you', 'i am fine'],
    'abecedario': [],
    'numeros': ['zero', 'one', 'two', 'three', 'four', 'five', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'one hundred', 'one thousand', 'birthday', 'age', 'how old'],
    'presentarse': ['name', 'surname', 'nice to meet you', 'how are you', 'i am fine', 'hello', 'student', 'teacher'],
    'paises': ['country', 'nationality', 'mexican', 'american', 'english', 'spanish'],
    'cortesia': ['please', 'thank you', 'you are welcome', 'excuse me', 'sorry'],
    'materias': ['lesson', 'exam', 'homework', 'classroom', 'school', 'university'],
    'utiles': ['notebook', 'pencil', 'pen', 'book', 'backpack', 'eraser', 'ruler'],
    'profesiones': ['teacher', 'student', 'doctor', 'nurse', 'engineer', 'designer', 'waiter', 'lawyer', 'police officer', 'firefighter'],
    'trabajo': ['office', 'job', 'salary', 'meeting', 'interview', 'manager', 'client'],
    'estudio': ['homework', 'exam', 'notebook', 'pencil', 'lesson', 'study'],
    'entrevistas': ['interview', 'job', 'salary', 'engineer', 'designer', 'manager'],
    'frutas': ['apple', 'banana', 'orange', 'strawberry', 'grapes', 'carrot', 'potato', 'tomato'],
    'comidas': ['breakfast', 'lunch', 'dinner', 'snack', 'bread', 'rice', 'beans', 'chicken', 'beef', 'fish', 'egg', 'cheese'],
    'restaurante': ['menu', 'bill', 'waiter', 'delicious', 'order', 'i would like', 'could i have'],
    'bebidas': ['water', 'milk', 'coffee', 'tea', 'juice', 'a glass of', 'a cup of'],
    'cocinar': ['cook', 'rice', 'beans', 'chicken', 'beef', 'fish', 'egg', 'cheese', 'bread'],
    'pedir comida': ['menu', 'bill', 'waiter', 'i would like', 'could i have', 'for here', 'to go'],
    'lugares': ['street', 'avenue', 'corner', 'traffic light', 'crosswalk', 'bridge', 'square', 'park', 'museum', 'hospital', 'pharmacy', 'bank', 'library', 'post office'],
    'direcciones': ['turn left', 'turn right', 'go straight', 'nearby', 'far', 'corner', 'street', 'avenue'],
    'preposiciones': ['in', 'on', 'under', 'next to', 'between', 'behind', 'in front of'],
    'transporte': ['bus stop', 'train station', 'airport', 'ticket', 'bus', 'train', 'flight'],
    'indicaciones': ['turn left', 'turn right', 'go straight', 'nearby', 'far'],
    'rutina diaria': ['wake up', 'get up', 'take a shower', 'get dressed', 'have breakfast', 'go to work', 'have lunch', 'come home', 'go to bed', 'early', 'late'],
    'pasatiempos': ['hobby', 'reading', 'drawing', 'painting', 'singing', 'dancing', 'swimming', 'running', 'cycling', 'hiking', 'photography', 'gardening', 'gaming', 'movie', 'concert', 'free time'],
    'habitos saludables': ['exercise', 'relax', 'healthy', 'drink water', 'rest', 'sleep'],
    'deporte': ['exercise', 'swimming', 'running', 'cycling', 'hiking', 'rest'],
    'familia': ['mother', 'father', 'parents', 'sister', 'brother', 'daughter', 'son', 'grandmother', 'grandfather', 'cousin', 'aunt', 'uncle', 'husband', 'wife'],
    'apariencia': ['tall', 'short', 'young', 'old', 'hair', 'eyes'],
    'personalidad': ['kind', 'funny', 'shy', 'friendly', 'confident'],
    'casa': ['house', 'apartment', 'bedroom', 'kitchen', 'bathroom', 'living room', 'garden'],
    'muebles': ['table', 'chair', 'bed', 'pillow', 'blanket', 'mirror', 'lamp', 'shelf'],
    'objetos': ['door', 'window', 'table', 'chair', 'pillow', 'blanket', 'mirror', 'lamp', 'fridge', 'shelf'],
    'tareas domesticas': ['clean', 'sweep', 'cook', 'wash', 'cleaning'],
    'habitacion': ['bedroom', 'bed', 'pillow', 'blanket', 'mirror', 'lamp', 'shelf', 'window'],
    'dias': ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
    'meses': ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'],
    'estaciones': ['spring', 'summer', 'autumn', 'fall', 'winter'],
    'clima': ['sunny', 'cloudy', 'rainy', 'windy', 'storm', 'weather', 'warm', 'cold'],
    'temperaturas': ['warm', 'cold', 'hot', 'cool', 'weather'],
    'tiendas': ['shop', 'store', 'market', 'price', 'discount', 'receipt', 'sale'],
    'ropa': ['shirt', 'pants', 'dress', 'shoes', 'size', 'small', 'medium', 'large', 'try on', 'fit'],
    'precios': ['price', 'cheap', 'expensive', 'discount', 'cash', 'change', 'how much is it'],
    'pagos': ['cash', 'credit card', 'wallet', 'change', 'receipt'],
    'comparar': ['cheap', 'expensive', 'small', 'medium', 'large', 'better', 'bigger'],
    'devoluciones': ['refund', 'exchange', 'receipt', 'sale'],
    'viaje': ['trip', 'travel', 'ticket', 'passport', 'visa', 'luggage', 'suitcase', 'flight'],
    'aeropuerto': ['boarding pass', 'flight', 'gate', 'departure', 'arrival', 'airport', 'luggage'],
    'hotel': ['hotel', 'reservation', 'reception', 'single room', 'double room', 'key'],
    'equipaje': ['luggage', 'suitcase', 'bag', 'passport'],
    'turismo': ['tour', 'guide', 'souvenir', 'museum', 'beach', 'park'],
    'imprevistos': ['lost', 'delayed', 'help', 'emergency', 'problem'],
    'cuerpo': ['head', 'neck', 'shoulder', 'arm', 'hand', 'finger', 'back', 'leg', 'knee', 'foot', 'stomach'],
    'sintomas': ['headache', 'fever', 'cough', 'cold', 'pain', 'tired'],
    'medico': ['medicine', 'appointment', 'doctor', 'headache', 'fever', 'cough', 'pain'],
    'dispositivos': ['computer', 'laptop', 'keyboard', 'screen', 'mouse', 'headphones', 'charger', 'battery'],
    'internet': ['website', 'download', 'upload', 'connection', 'password'],
    'aplicaciones': ['application', 'app', 'settings', 'file', 'folder', 'update'],
    'mensajes': ['message', 'call', 'attachment', 'email', 'reply'],
    'problemas tecnicos': ['battery', 'charger', 'connection', 'update', 'screen', 'broken'],
    'seguridad': ['password', 'username', 'privacy', 'settings'],
    'domesticos': ['dog', 'cat', 'bird', 'horse', 'rabbit', 'cow', 'sheep'],
    'salvajes': ['fox', 'bear', 'wolf', 'deer', 'eagle'],
    'paisajes': ['forest', 'mountain', 'river', 'lake', 'ocean', 'beach'],
    'plantas': ['tree', 'flower', 'garden'],
    'medio ambiente': ['environment', 'recycle', 'pollution'],
    'emociones': ['happy', 'sad', 'angry', 'worried', 'excited', 'nervous', 'surprised', 'bored', 'relaxed', 'proud', 'afraid', 'confident'],
    'opiniones': ['i think', 'i believe', 'in my opinion', 'maybe', 'probably', 'it depends'],
    'acuerdo': ['i agree', 'i disagree', 'that makes sense', 'fair enough'],
    'phrasal': ['find out', 'give up', 'look after', 'carry on', 'put off', 'run out of'],
    'conectores': ['although', 'however', 'therefore', 'moreover', 'unless', 'despite', 'as a result'],
    'idiomaticas': ['by the way', 'no worries', 'long time no see', 'how come', 'never mind', 'hang on'],
    'comunicacion profesional': ['deadline', 'schedule', 'task', 'project', 'team', 'colleague', 'manager', 'client', 'feedback', 'report'],
    'correos': ['email', 'attachment', 'forward', 'reply', 'please find attached'],
    'reuniones': ['meeting', 'meeting room', 'schedule', 'available', 'busy'],
    'proyectos': ['deadline', 'task', 'project', 'team', 'report', 'feedback'],
    'cliente': ['client', 'customer', 'feedback', 'invoice', 'available'],
    'cafeteria': ['coffee', 'tea', 'menu', 'bill', 'i would like', 'for here', 'to go'],
    'banco': ['account', 'cash machine', 'withdraw', 'deposit', 'cash', 'credit card'],
    'farmacia': ['prescription', 'dosage', 'allergic', 'medicine'],
    'ayuda': ['help me', 'i need assistance', 'emergency', 'police station', 'fire department'],
    'quejas': ['it is broken', 'there is a problem', 'i would like a refund'],
    'cardinales': ['zero', 'one', 'two', 'three', 'four', 'five', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'one hundred', 'one thousand'],
    'ordinales': ['first', 'second', 'third', 'fourth'],
    'fechas': ['birthday', 'date', 'year', 'month', 'week', 'january', 'february'],
    'horas': ['hour', 'minute', 'second', 'at noon', 'at midnight'],
    'medidas': ['kilometer', 'meter', 'liter', 'kilo', 'half', 'quarter', 'how many', 'how much'],
    'moverse': ['street', 'avenue', 'bus stop', 'train station', 'turn left', 'turn right', 'go straight'],
    'fin de semana': ['hobby', 'movie', 'concert', 'free time', 'enjoy', 'prefer'],
    'estilo de vida': ['wake up', 'exercise', 'relax', 'healthy', 'free time', 'go to bed'],
    'describir personas': ['tall', 'short', 'kind', 'funny', 'shy', 'friendly'],
    'relaciones': ['mother', 'father', 'parents', 'sister', 'brother', 'cousin', 'husband', 'wife'],
    'describir mi hogar': ['house', 'apartment', 'bedroom', 'kitchen', 'garden', 'clean'],
    'pronostico': ['sunny', 'cloudy', 'rainy', 'windy', 'storm', 'weather', 'warm', 'cold'],
    'formas de pago': ['cash', 'credit card', 'wallet', 'change', 'receipt'],
    'ejercicio y descanso': ['exercise', 'running', 'swimming', 'rest', 'tired', 'healthy'],
    'recomendaciones': ['healthy', 'rest', 'drink water', 'exercise', 'medicine'],
    'cuidar el planeta': ['environment', 'recycle', 'pollution', 'tree', 'flower'],
    'estados de animo': ['happy', 'sad', 'angry', 'worried', 'excited', 'nervous', 'bored', 'relaxed'],
    'experiencias': ['yesterday', 'last week', 'before', 'after', 'already', 'yet'],
    'conversaciones reales': ['i think', 'i believe', 'i agree', 'i disagree', 'maybe', 'probably'],
    'presente simple': ['usually', 'every day', 'always', 'often', 'sometimes', 'never', 'do', 'does'],
    'presente continuo': ['right now', 'at the moment', 'studying', 'working', 'watching'],
    'pasado simple': ['yesterday', 'last week', 'before', 'after', 'was', 'were', 'did'],
    'futuro con going to': ['tomorrow', 'next month', 'going to', 'will'],
    'articulos': ['a', 'an', 'the', 'some', 'any'],
    'pronombres': ['their', 'our', 'mine', 'my', 'your', 'his', 'her'],
    'negociacion': ['could you', 'deadline', 'schedule', 'client', 'feedback', 'available'],
    'small talk': ['actually', 'by the way', 'sounds good', 'no worries', 'long time no see'],
    'anecdotas': ['it turns out', 'yesterday', 'last week', 'before', 'after', 'actually'],
    'sugerencias': ['let me think', 'sounds good', 'maybe', 'could you', 'how about'],
    'malentendidos': ['what do you mean', 'i mean', 'never mind', 'that makes sense', 'hang on'],
    'expresiones naturales': ['actually', 'by the way', 'no worries', 'fair enough', 'definitely'],
    'telefonica': ['call', 'hang on', 'can you hear me', 'connection', 'message'],
    'emergencias': ['emergency', 'help me', 'i need assistance', 'police station', 'fire department'],
    'matices': ['although', 'however', 'to some extent', 'in the long run', 'despite'],
    'argumentar': ['i think', 'i believe', 'in my opinion', 'therefore', 'moreover', 'on the other hand'],
    'comprension avanzada': ['although', 'however', 'therefore', 'moreover', 'as a result', 'it goes without saying'],
    'calculos': ['how many', 'how much', 'half', 'quarter', 'meter', 'liter', 'kilo'],
  };

  static List<String> _clavesPara(String titulo) {
    final t = _normalizar(titulo);
    for (final entry in _temas.entries) {
      if (t.contains(entry.key)) return entry.value;
    }
    return const [];
  }

  static ContenidoCapitulo crear(UnidadModel unidad, int indice) {
    final titulo = indice >= 0 && indice < unidad.capitulos.length
        ? unidad.capitulos[indice] : unidad.nombre;
    final claves = _clavesPara(titulo);
    var vocab = unidad.vocabulario.where((p) {
      final en = _normalizar(p['en'] ?? '');
      return en.isNotEmpty && claves.any((k) { final clave = _normalizar(k); return en == clave || (clave.length > 3 && (en.contains(clave) || clave.contains(en))); });
    }).toList();
    final sugeridas = _vocabularioSugerido(titulo);
    if (vocab.isEmpty) {
      vocab = sugeridas;
    } else if (vocab.length < 4) {
      final existentes = vocab.map((p) => _normalizar(p['en'] ?? '')).toSet();
      vocab = [...vocab, ...sugeridas.where((p) => !existentes.contains(_normalizar(p['en'] ?? ''))).take(4 - vocab.length)];
    }

    final tema = _normalizar(titulo);
    final regla = _reglaPara(tema, vocab);
    final ejemplos = _ejemplosPara(tema, vocab);
    final preguntas = _preguntasPara(tema, vocab);
    return ContenidoCapitulo(
      titulo: titulo,
      objetivo: _objetivoPara(tema),
      explicacion: regla,
      vocabulario: vocab,
      ejemplos: ejemplos,
      gramatica: preguntas,
    );
  }

  static List<Map<String, String>> _vocabularioSugerido(String titulo) {
    final t = _normalizar(titulo);
    final grupos = <String, List<List<String>>>{
      'abecedario': [['letter', 'letra'], ['spell', 'deletrear'], ['alphabet', 'abecedario']],
      'materias': [['math', 'matemáticas'], ['science', 'ciencias'], ['history', 'historia'], ['English', 'inglés']],
      'utiles': [['notebook', 'cuaderno'], ['pencil', 'lápiz'], ['eraser', 'borrador'], ['backpack', 'mochila']],
      'estaciones': [['spring', 'primavera'], ['summer', 'verano'], ['autumn', 'otoño'], ['winter', 'invierno']],
      'temperaturas': [['hot', 'caluroso'], ['cold', 'frío'], ['warm', 'templado'], ['cool', 'fresco']],
      'ropa': [['shirt', 'camisa'], ['trousers', 'pantalones'], ['shoes', 'zapatos'], ['dress', 'vestido']],
      'preposiciones': [['in', 'dentro de'], ['on', 'sobre'], ['under', 'debajo de'], ['next to', 'junto a']],
      'horas': [['hour', 'hora'], ['minute', 'minuto'], ['half past', 'y media'], ['quarter past', 'y cuarto']],
      'ordinales': [['first', 'primero'], ['second', 'segundo'], ['third', 'tercero'], ['fourth', 'cuarto']],
      'medidas': [['meter', 'metro'], ['kilometer', 'kilómetro'], ['liter', 'litro'], ['kilo', 'kilo']],
      'plantas': [['tree', 'árbol'], ['flower', 'flor'], ['leaf', 'hoja'], ['grass', 'pasto']],
      'salvajes': [['fox', 'zorro'], ['bear', 'oso'], ['wolf', 'lobo'], ['eagle', 'águila']],
      'dispositivos': [['computer', 'computadora'], ['keyboard', 'teclado'], ['screen', 'pantalla'], ['charger', 'cargador']],
      'internet': [['website', 'sitio web'], ['browser', 'navegador'], ['download', 'descargar'], ['password', 'contraseña']],
      'mensajes': [['message', 'mensaje'], ['call', 'llamada'], ['reply', 'responder'], ['attachment', 'archivo adjunto']],
      'emociones': [['happy', 'feliz'], ['worried', 'preocupado'], ['excited', 'emocionado'], ['nervous', 'nervioso']],
      'phrasal': [['find out', 'averiguar'], ['give up', 'rendirse'], ['look after', 'cuidar'], ['put off', 'posponer']],
      'conectores': [['although', 'aunque'], ['however', 'sin embargo'], ['therefore', 'por lo tanto'], ['moreover', 'además']],
      'entrevistas': [['experience', 'experiencia'], ['strength', 'fortaleza'], ['skill', 'habilidad'], ['available', 'disponible']],
      'reuniones': [['agenda', 'orden del día'], ['attendee', 'asistente'], ['minutes', 'acta'], ['schedule', 'horario']],
      'correos': [['subject', 'asunto'], ['attachment', 'archivo adjunto'], ['forward', 'reenviar'], ['regards', 'saludos']],
      'hotel': [['reservation', 'reservación'], ['reception', 'recepción'], ['single room', 'habitación individual'], ['key', 'llave']],
      'aeropuerto': [['boarding pass', 'pase de abordar'], ['departure', 'salida'], ['arrival', 'llegada'], ['gate', 'puerta de embarque']],
      'cuerpo': [['head', 'cabeza'], ['shoulder', 'hombro'], ['knee', 'rodilla'], ['stomach', 'estómago']],
      'ayuda': [['help', 'ayuda'], ['assistance', 'asistencia'], ['emergency', 'emergencia'], ['safe', 'seguro']],
      'banco': [['account', 'cuenta'], ['withdraw', 'retirar'], ['deposit', 'depositar'], ['cash machine', 'cajero automático']],
      'rutina': [['wake up', 'despertarse'], ['get dressed', 'vestirse'], ['have breakfast', 'desayunar'], ['go to bed', 'acostarse']],
      'pasatiempos': [['reading', 'leer'], ['dancing', 'bailar'], ['drawing', 'dibujar'], ['hiking', 'hacer senderismo']],
      'frut': [['apple', 'manzana'], ['banana', 'plátano'], ['carrot', 'zanahoria'], ['grapes', 'uvas']],
      'bebida': [['water', 'agua'], ['coffee', 'café'], ['tea', 'té'], ['milk', 'leche']],
      'cocinar': [['chop', 'picar'], ['boil', 'hervir'], ['fry', 'freír'], ['bake', 'hornear']],
      'comprar': [['price', 'precio'], ['receipt', 'recibo'], ['discount', 'descuento'], ['refund', 'reembolso']],
      'moverse': [['get around', 'desplazarse'], ['bus stop', 'parada de autobús'], ['train station', 'estación de tren']],
      'fin de semana': [['weekend', 'fin de semana'], ['hang out', 'pasar el rato'], ['free time', 'tiempo libre']],
      'estilo de vida': [['lifestyle', 'estilo de vida'], ['habit', 'hábito'], ['routine', 'rutina']],
      'describir': [['tall', 'alto'], ['short', 'bajo'], ['friendly', 'amigable'], ['curly hair', 'cabello rizado']],
      'relaciones': [['friend', 'amigo'], ['partner', 'pareja'], ['relationship', 'relación']],
      'hogar': [['cozy', 'acogedor'], ['quiet', 'tranquilo'], ['spacious', 'espacioso']],
      'pronostico': [['forecast', 'pronóstico'], ['temperature', 'temperatura'], ['chance of rain', 'probabilidad de lluvia']],
      'formas de pago': [['debit card', 'tarjeta de débito'], ['contactless', 'sin contacto'], ['payment', 'pago']],
      'descanso': [['sleep', 'dormir'], ['rest', 'descansar'], ['stretch', 'estirar']],
      'recomendaciones': [['you should', 'deberías'], ['you could', 'podrías'], ['avoid', 'evitar']],
      'planeta': [['reusable', 'reutilizable'], ['waste', 'residuos'], ['save energy', 'ahorrar energía']],
      'experiencias': [['experience', 'experiencia'], ['memory', 'recuerdo'], ['moment', 'momento']],
      'conversaciones': [['in my opinion', 'en mi opinión'], ['I agree', 'estoy de acuerdo'], ['it depends', 'depende']],
      'presente simple': [['every day', 'todos los días'], ['usually', 'usualmente'], ['sometimes', 'a veces']],
      'presente continuo': [['right now', 'ahora mismo'], ['at the moment', 'en este momento'], ['working', 'trabajando']],
      'pasado simple': [['yesterday', 'ayer'], ['last night', 'anoche'], ['last week', 'la semana pasada']],
      'futuro': [['tomorrow', 'mañana'], ['next week', 'la próxima semana'], ['going to', 'ir a']],
      'articulos': [['a', 'un/una'], ['an', 'un/una'], ['the', 'el/la/los/las']],
      'pronombres': [['mine', 'mío'], ['yours', 'tuyo'], ['theirs', 'de ellos']],
      'negociacion': [['proposal', 'propuesta'], ['offer', 'oferta'], ['agreement', 'acuerdo']],
      'small talk': [['how is it going?', '¿cómo va todo?'], ['nice weather', 'buen clima'], ['what have you been up to?', '¿qué has hecho?']],
      'anecdotas': [['once upon a time', 'érase una vez'], ['at first', 'al principio'], ['eventually', 'finalmente']],
      'sugerencias': [['how about', 'qué tal si'], ['why dont we', 'por qué no'], ['lets', 'vamos a']],
      'malentendidos': [['I beg your pardon', '¿cómo dice?'], ['to clarify', 'para aclarar'], ['misunderstanding', 'malentendido']],
      'expresiones': [['fair enough', 'está bien'], ['no worries', 'no te preocupes'], ['definitely', 'definitivamente']],
      'telefonica': [['may I speak to', '¿puedo hablar con?'], ['hold on', 'espere'], ['bad signal', 'mala señal'], ['call back', 'devolver la llamada']],
      'emergencias': [['ambulance', 'ambulancia'], ['fire', 'incendio'], ['police', 'policía']],
      'matices': [['somewhat', 'algo'], ['rather', 'más bien'], ['nevertheless', 'no obstante']],
      'argumentar': [['evidence', 'evidencia'], ['claim', 'afirmación'], ['point of view', 'punto de vista']],
      'comprension': [['main idea', 'idea principal'], ['detail', 'detalle'], ['context', 'contexto']],
      'calculos': [['add', 'sumar'], ['subtract', 'restar'], ['multiply', 'multiplicar'], ['divide', 'dividir']],
      'numeros': [['zero', 'cero'], ['one', 'uno'], ['ten', 'diez'], ['twenty', 'veinte'], ['how old', 'cuántos años']],
      'paises': [['country', 'país'], ['nationality', 'nacionalidad'], ['Mexican', 'mexicano'], ['language', 'idioma']],
      'cortesia': [['please', 'por favor'], ['thank you', 'gracias'], ['you are welcome', 'de nada'], ['excuse me', 'disculpe']],
      'habitos saludables': [['balanced diet', 'dieta equilibrada'], ['sleep well', 'dormir bien'], ['stretch', 'estirar'], ['take a break', 'tomar un descanso']],
      'tareas domesticas': [['wash the dishes', 'lavar los platos'], ['do the laundry', 'lavar la ropa'], ['make the bed', 'tender la cama'], ['take out the trash', 'sacar la basura']],
      'habitacion': [['bedroom', 'dormitorio'], ['bed', 'cama'], ['pillow', 'almohada'], ['blanket', 'cobija']],
      'sintomas': [['headache', 'dolor de cabeza'], ['fever', 'fiebre'], ['cough', 'tos'], ['stomachache', 'dolor de estómago']],
      'medico': [['appointment', 'cita médica'], ['doctor', 'médico'], ['medicine', 'medicina'], ['symptom', 'síntoma']],
      'problemas tecnicos': [['crash', 'fallo'], ['frozen', 'bloqueado'], ['restart', 'reiniciar'], ['error message', 'mensaje de error']],
      'domesticos': [['dog', 'perro'], ['cat', 'gato'], ['rabbit', 'conejo'], ['bird', 'pájaro']],
      'animo': [['cheerful', 'alegre'], ['upset', 'molesto'], ['calm', 'tranquilo'], ['lonely', 'solo']],
      'comunicacion profesional': [['deadline', 'fecha límite'], ['colleague', 'compañero'], ['feedback', 'comentarios'], ['report', 'informe']],
      'cafeteria': [['coffee', 'café'], ['tea', 'té'], ['for here', 'para comer aquí'], ['to go', 'para llevar']],
      'restaurante': [['waiter', 'mesero'], ['order', 'ordenar'], ['reservation', 'reservación'], ['tip', 'propina']],
      'pedir comida': [['could I have', '¿me podría dar?'], ['I would like', 'quisiera'], ['for here', 'para comer aquí'], ['to go', 'para llevar']],
      'comidas del dia': [['snack', 'refrigerio'], ['meal', 'comida'], ['have breakfast', 'desayunar'], ['have dinner', 'cenar']],
      'frutas': [['fruit', 'fruta'], ['vegetable', 'verdura'], ['lettuce', 'lechuga'], ['onion', 'cebolla']],
      'profesiones': [['architect', 'arquitecto'], ['chef', 'chef'], ['mechanic', 'mecánico'], ['accountant', 'contador']],
      'estudio': [['revise', 'repasar'], ['learn', 'aprender'], ['pass an exam', 'aprobar un examen'], ['fail', 'reprobar']],
      'trabajo': [['workplace', 'lugar de trabajo'], ['colleague', 'compañero'], ['department', 'departamento'], ['career', 'carrera']],
      'bebidas': [['juice', 'jugo'], ['soda', 'refresco'], ['hot chocolate', 'chocolate caliente'], ['lemonade', 'limonada']],
    };
    for (final entry in grupos.entries) {
      if (t.contains(entry.key)) {
        return entry.value.map((p) => {'en': p[0], 'es': p[1]}).toList();
      }
    }
    return const [];
  }

  static String _objetivoPara(String t) {
    if (t.contains('frut') || t.contains('verdura')) return 'Identificar frutas y verduras y nombrarlas en oraciones sencillas.';
    if (t.contains('restaurante') || t.contains('pedir comida')) return 'Pedir alimentos con cortesía, comprender el menú y solicitar la cuenta.';
    if (t.contains('bebida') || t.contains('cantidades')) return 'Nombrar bebidas y expresar cantidades de forma natural.';
    if (t.contains('familia')) return 'Hablar de tus familiares y explicar cómo están relacionados contigo.';
    if (t.contains('direcciones') || t.contains('indicaciones')) return 'Preguntar y explicar cómo llegar a un lugar.';
    if (t.contains('rutina')) return 'Describir actividades habituales y cuándo las realizas.';
    if (t.contains('entrevista')) return 'Responder preguntas sencillas sobre experiencia, habilidades y trabajo.';
    if (t.contains('clima') || t.contains('pronostico')) return 'Describir el tiempo y relacionarlo con tus planes.';
    if (t.contains('pasado')) return 'Contar acciones que comenzaron y terminaron en el pasado.';
    if (t.contains('futuro')) return 'Hablar de planes e intenciones futuras.';
    if (t.contains('presente continuo')) return 'Describir acciones que están ocurriendo ahora.';
    if (t.contains('presente simple')) return 'Expresar rutinas, hechos y hábitos.';
    if (t.contains('correo') || t.contains('email')) return 'Redactar mensajes profesionales claros y educados.';
    if (t.contains('emocion') || t.contains('estado de animo')) return 'Expresar cómo te sientes y reconocer emociones.';
    if (t.contains('viaje') || t.contains('aeropuerto') || t.contains('hotel')) return 'Resolver situaciones frecuentes durante un viaje.';
    return 'Comprender y utilizar expresiones relacionadas con "$t" en situaciones cotidianas.';
  }

  static String _reglaPara(String t, List<Map<String, String>> vocab) {
    if (t.contains('frut') || t.contains('verdura') || t.contains('objetos') || t.contains('muebles')) return 'Para hablar de un objeto singular usa a/an: an apple, a carrot. Para varios, normalmente agrega -s: apples, carrots.';
    if (t.contains('restaurante') || t.contains('pedir comida') || t.contains('cafeteria')) return 'Para pedir con cortesía puedes usar “I would like…” o “Could I have…?”. Ejemplo: “I would like a coffee, please.”';
    if (t.contains('bebida') || t.contains('cantidades') || t.contains('medidas')) return 'Usa “a glass of” para un vaso y “a cup of” para una taza. “How much” pregunta por cantidades incontables y “how many” por elementos contables.';
    if (t.contains('comidas del dia') || t.contains('comidas')) return 'Para hablar de tus comidas usa el presente simple: “I have breakfast at seven”. Con he/she/it, el verbo lleva -s: “She has lunch at one”.';
    if (t.contains('familia') || t.contains('apariencia') || t.contains('personalidad')) return 'Usa “to be” para describir: “My sister is kind.” Para posesión utiliza my, your, his, her, our o their.';
    if (t.contains('direcciones') || t.contains('indicaciones')) return 'Para dar instrucciones usa el imperativo: “Turn left”, “Go straight” y “Cross the street”. No necesitas escribir el sujeto you.';
    if (t.contains('preposiciones')) return 'Las preposiciones indican ubicación: in (dentro), on (encima), under (debajo), next to (junto a), between (entre) y behind (detrás).';
    if (t.contains('ropa') || t.contains('tallas')) return 'Para preguntar por una talla usa “Do you have this in medium?”. Para describir ajuste puedes decir “It fits” o “It is too small”.';
    if (t.contains('describir personas')) return 'Usa to be + adjetivo para describir: “She is tall”. Para el cabello y los ojos puedes usar has: “He has brown eyes”.';
    if (t.contains('transporte')) return 'Usa “by” para el medio de transporte: by bus, by train. Para preguntar una ruta: “How can I get to the station?”.';
    if (t.contains('rutina') || t.contains('habitos')) return 'El presente simple describe hábitos. Con he, she e it agrega -s/-es: “She wakes up early”. Con I/you/we/they usa la forma base.';
    if (t.contains('entrevista') || t.contains('trabajo')) return 'Para hablar de habilidades usa “I can…”. Para experiencia puedes usar “I have experience in…” y para pedir algo con cortesía “Could you…?”.';
    if (t.contains('pasado')) return 'El pasado simple habla de acciones terminadas. Los verbos regulares suelen terminar en -ed; los irregulares tienen formas propias.';
    if (t.contains('futuro') || t.contains('planes')) return 'Para planes decididos usa “be going to”: sujeto + am/is/are + going to + verbo base.';
    if (t.contains('presente continuo')) return 'Para acciones que ocurren ahora usa am/is/are + verbo terminado en -ing: “They are studying”.';
    if (t.contains('presente simple')) return 'El presente simple expresa rutinas y hechos. En preguntas usa do/does; después de does el verbo vuelve a su forma base.';
    if (t.contains('numero') || t.contains('edad')) return 'Para preguntar la edad usa “How old are you?”. Responde con “I am + número + years old”. Los números también sirven para cantidades y precios.';
    if (t.contains('pais') || t.contains('nacionalidad')) return 'Los países son nombres propios y las nacionalidades se escriben con mayúscula: Mexico, Mexican; Japan, Japanese. Usa “I am from…” para decir de dónde eres.';
    if (t.contains('cortesia')) return 'Please suaviza una petición, thank you agradece y excuse me sirve para llamar la atención o disculparse antes de interrumpir.';
    if (t.contains('utiles') || t.contains('materiales')) return 'Para indicar posesión usa “This is my…” y “These are my…”. This/that se usan con singular; these/those con plural.';
    if (t.contains('emocion') || t.contains('estado de animo')) return 'Usa “I feel…” o “I am…” para expresar emociones: “I feel nervous” / “I am happy”.';
    if (t.contains('comparar')) return 'Para comparar dos cosas usa adjetivo + -er + than o “more” + adjetivo + than: “cheaper than”, “more expensive than”.';
    if (t.contains('correo') || t.contains('email')) return 'En correos profesionales usa saludos claros, peticiones con “Could you…?” y cierres como “Best regards”.';
    if (t.contains('conectores')) return 'Los conectores relacionan ideas: although (contraste), however (sin embargo), therefore (por lo tanto) y moreover (además).';
    if (t.contains('articulos') || t.contains('plurales')) return 'Usa a antes de sonido consonántico y an antes de sonido vocálico. Para plurales regulares suele agregarse -s o -es: book/books, box/boxes.';
    if (t.contains('pago') || t.contains('precio') || t.contains('compras') || t.contains('devoluciones')) return 'Para preguntar precios usa “How much is…?”. Para hablar del método de pago se usa “by card” o “in cash”. En compras, compara con cheaper than y more expensive than.';
    if (t.contains('viaje') || t.contains('aeropuerto') || t.contains('hotel') || t.contains('equipaje')) return 'Usa preguntas con where para localizar servicios y objetos: “Where is the gate?”. Usa have para reservas y posesiones: “I have a reservation”.';
    if (t.contains('tecnologia') || t.contains('internet') || t.contains('dispositivo') || t.contains('seguridad')) return 'Usa imperativos para instrucciones: “Open the settings”. Para consejos usa should: “You should protect your password”.';
    if (t.contains('animal') || t.contains('salvaje') || t.contains('domestico')) return 'Usa can para expresar habilidades: “A bird can fly”. Can no cambia con he, she o it y va seguido del verbo base.';
    if (t.contains('casa') || t.contains('hogar') || t.contains('mueble') || t.contains('habitacion')) return 'Usa there is con un elemento singular y there are con varios: “There is a bed” / “There are two chairs”.';
    if (t.contains('saludo') || t.contains('presentarse') || t.contains('nacionalidad')) return 'Para presentarte usa el verbo to be: “I am…”, “You are…” y “She is…”. Las nacionalidades suelen escribirse con mayúscula en inglés.';
    if (t.contains('hora') || t.contains('fecha') || t.contains('numero')) return 'Usa at para horas exactas (at 8), on para días y fechas (on Monday) e in para meses y años (in May, in 2026).';
    if (t.contains('salud') || t.contains('sintoma') || t.contains('recomendacion')) return 'Para dar consejos usa should + verbo base: “You should rest”. Para describir síntomas puedes usar “I have a headache” o “I feel tired”.';
    if (t.contains('pronombres') || t.contains('posesivos')) return 'Los pronombres sustituyen al sustantivo (I, you, he, she, it, we, they). Los posesivos indican pertenencia: mine, yours, his, hers, ours, theirs.';
    if (t.contains('abecedario')) return 'En inglés, las letras tienen nombres y sonidos propios. Para deletrear, di cada letra por separado; puedes iniciar con “How do you spell…?”.';
    if (t.contains('ordinales')) return 'Los ordinales indican posición: first, second, third. Se usan en fechas y para ordenar elementos.';
    if (t.contains('negociacion')) return 'Para negociar con cortesía usa could, would y expresiones como “Would you consider…?” o “Could we agree on…?”.';
    return 'Observa cómo se usa cada expresión dentro de una oración completa. Recuerda la concordancia entre sujeto y verbo y que después de should se utiliza el verbo en su forma base.';
  }

  static List<String> _ejemplosPara(String t, List<Map<String, String>> vocab) {
    if (t.contains('frut') || t.contains('verdura')) return ['I eat an apple every morning. — Como una manzana cada mañana.', 'Carrots are orange. — Las zanahorias son naranjas.'];
    if (t.contains('restaurante') || t.contains('pedir comida') || t.contains('cafeteria')) return ['Could I have the menu, please? — ¿Me trae el menú, por favor?', 'I would like the chicken. — Quisiera el pollo.'];
    if (t.contains('bebida')) return ['A glass of water, please. — Un vaso de agua, por favor.', 'How much milk do we need? — ¿Cuánta leche necesitamos?'];
    if (t.contains('comidas')) return ['I have breakfast at seven. — Desayuno a las siete.', 'She has dinner with her family. — Ella cena con su familia.'];
    if (t.contains('familia')) return ['This is my mother. — Esta es mi madre.', 'My brother is funny. — Mi hermano es divertido.'];
    if (t.contains('direcciones') || t.contains('indicaciones')) return ['Go straight and turn left. — Sigue derecho y gira a la izquierda.', 'The bank is next to the library. — El banco está junto a la biblioteca.'];
    if (t.contains('preposiciones')) return ['The keys are on the table. — Las llaves están sobre la mesa.', 'The bag is under the chair. — La bolsa está debajo de la silla.'];
    if (t.contains('ropa') || t.contains('tallas')) return ['Do you have this shirt in medium? — ¿Tienes esta camisa en mediana?', 'These shoes are too small. — Estos zapatos son demasiado pequeños.'];
    if (t.contains('describir personas')) return ['She is tall and friendly. — Ella es alta y amigable.', 'He has brown eyes. — Él tiene ojos cafés.'];
    if (t.contains('transporte')) return ['I go to work by bus. — Voy al trabajo en autobús.', 'Where is the train station? — ¿Dónde está la estación de tren?'];
    if (t.contains('rutina')) return ['I wake up at seven. — Me despierto a las siete.', 'She goes to work by bus. — Ella va al trabajo en autobús.'];
    if (t.contains('pasado')) return ['I visited my friend yesterday. — Visité a mi amigo ayer.', 'They went home late. — Ellos fueron a casa tarde.'];
    if (t.contains('futuro')) return ['I am going to study tonight. — Voy a estudiar esta noche.', 'We are going to travel. — Vamos a viajar.'];
    if (t.contains('presente continuo')) return ['I am learning English now. — Estoy aprendiendo inglés ahora.', 'They are having lunch. — Ellos están comiendo.'];
    if (t.contains('presente simple')) return ['I study every day. — Estudio todos los días.', 'He works at a school. — Él trabaja en una escuela.'];
    if (t.contains('hotel')) return ['I have a reservation. — Tengo una reservación.', 'Could I have the room key? — ¿Me da la llave de la habitación?'];
    if (t.contains('aeropuerto')) return ['Where is gate five? — ¿Dónde está la puerta cinco?', 'My flight is delayed. — Mi vuelo está retrasado.'];
    if (t.contains('clima') || t.contains('temperatura')) return ['It is sunny today. — Hoy está soleado.', 'It is cold and windy. — Hace frío y viento.'];
    if (t.contains('correo') || t.contains('email')) return ['Please find the report attached. — Adjunto encontrarás el informe.', 'Could you reply by Friday? — ¿Podrías responder antes del viernes?'];
    if (t.contains('emocion')) return ['I feel excited today. — Hoy me siento emocionado.', 'She is worried about the exam. — Ella está preocupada por el examen.'];
    if (t.contains('tienda') || t.contains('precio') || t.contains('pago')) return ['How much is this shirt? — ¿Cuánto cuesta esta camisa?', 'Can I pay by card? — ¿Puedo pagar con tarjeta?'];
    if (t.contains('tecnologia') || t.contains('internet')) return ['You should update the application. — Deberías actualizar la aplicación.', 'I forgot my password. — Olvidé mi contraseña.'];
    if (t.contains('animal')) return ['A rabbit can jump. — Un conejo puede saltar.', 'The eagle is a wild animal. — El águila es un animal salvaje.'];
    if (t.contains('casa') || t.contains('hogar') || t.contains('mueble')) return ['There is a table in the kitchen. — Hay una mesa en la cocina.', 'The lamp is next to the bed. — La lámpara está junto a la cama.'];
    if (t.contains('salud') || t.contains('sintoma')) return ['I have a headache. — Me duele la cabeza.', 'You should get some rest. — Deberías descansar.'];
    if (t.contains('hora') || t.contains('fecha')) return ['The class starts at nine. — La clase empieza a las nueve.', 'My birthday is in June. — Mi cumpleaños es en junio.'];
    if (vocab.isNotEmpty) {
      final p = vocab.first;
      return ['I can use “${p['en']}” in a conversation. — Puedo usar “${p['es']}” en una conversación.', 'This expression is useful. — Esta expresión es útil.'];
    }
    return ['This chapter is about $t. — Este capítulo trata sobre $t.', 'Try to use the new expressions in a complete sentence. — Usa las expresiones nuevas en una oración completa.'];
  }

  static List<Map<String, String>> _preguntasPara(String t, List<Map<String, String>> vocab) {
    Map<String, String> q(String sentence, String answer, String b, String c, String d, String why) => {'q': sentence, 'a': answer, 'b': b, 'c': c, 'd': d, 'why': why};
    if (t.contains('frut') || t.contains('verdura') || t.contains('objetos')) return [q('I eat ___ apple.', 'an', 'a', 'the', 'some', 'Usamos an antes de un sonido vocálico.'), q('Two ___ are on the table.', 'apples', 'apple', 'applees', 'an apple', 'Para formar el plural regular normalmente agregamos -s.')];
    if (t.contains('restaurante') || t.contains('pedir comida') || t.contains('cafeteria')) return [q('I ___ like a table for two, please.', 'would', 'will', 'am', 'do', 'Would like es una forma cortés de pedir.'), q('Could I ___ the menu?', 'have', 'has', 'having', 'had', 'Después de could usamos el verbo en forma base.')];
    if (t.contains('bebida') || t.contains('medidas')) return [q('A ___ of water, please.', 'glass', 'bottle of', 'many', 'few', 'Glass of expresa la cantidad servida en un vaso.'), q('How ___ cups do you need?', 'many', 'much', 'any', 'some', 'How many se usa con sustantivos contables en plural.')];
    if (t.contains('comidas')) return [q('She ___ breakfast at seven.', 'has', 'have', 'having', 'had', 'Con she usamos has en presente simple.'), q('I ___ lunch at noon.', 'have', 'has', 'having', 'had', 'Con I usamos have en presente simple.')];
    if (t.contains('familia') || t.contains('personalidad') || t.contains('apariencia')) return [q('My sister ___ very kind.', 'is', 'are', 'am', 'be', 'Con he, she e it usamos is.'), q('This is ___ brother.', 'my', 'me', 'I', 'mine is', 'My es el adjetivo posesivo que acompaña a brother.')];
    if (t.contains('direcciones') || t.contains('indicaciones')) return [q('___ straight for two blocks.', 'Go', 'Goes', 'Going', 'Went', 'Las instrucciones se expresan con el imperativo: verbo base.'), q('The bank is ___ to the park.', 'next', 'between', 'under', 'at', 'Next to significa junto a.')];
    if (t.contains('preposiciones')) return [q('The keys are ___ the table.', 'on', 'at', 'between', 'from', 'On indica que algo está sobre una superficie.'), q('The cat is ___ the chair.', 'under', 'between', 'at', 'from', 'Under significa debajo de.')];
    if (t.contains('ropa') || t.contains('tallas')) return [q('These shoes ___ too small.', 'are', 'is', 'am', 'be', 'Shoes es plural, por eso usamos are.'), q('Do you have this ___ medium?', 'in', 'on', 'at', 'by', 'Usamos in para preguntar si hay una prenda en determinada talla.')];
    if (t.contains('describir personas')) return [q('She ___ very friendly.', 'is', 'are', 'am', 'be', 'Con she usamos is.'), q('He ___ brown eyes.', 'has', 'have', 'having', 'is', 'Con he usamos has para expresar características físicas.')];
    if (t.contains('transporte')) return [q('I go to work ___ bus.', 'by', 'on', 'at', 'in', 'By bus expresa el medio de transporte.'), q('Where ___ the station?', 'is', 'are', 'am', 'be', 'Station es singular, por eso usamos is.')];
    if (t.contains('rutina') || t.contains('habitos')) return [q('She ___ up at seven.', 'wakes', 'wake', 'waking', 'woken', 'En presente simple, he/she/it lleva -s.'), q('I ___ breakfast every day.', 'have', 'has', 'having', 'had', 'Con I usamos la forma base have.')];
    if (t.contains('pasado')) return [q('Yesterday, we ___ a movie.', 'watched', 'watch', 'watches', 'watching', 'Yesterday indica pasado simple; watch es regular y añade -ed.'), q('She ___ to the store last night.', 'went', 'go', 'goes', 'going', 'Went es el pasado irregular de go.')];
    if (t.contains('futuro') || t.contains('planes')) return [q('They ___ going to travel.', 'are', 'is', 'am', 'be', 'Con they usamos are antes de going to.'), q('I am going to ___ tonight.', 'study', 'studies', 'studying', 'studied', 'Después de going to usamos el verbo base.')];
    if (t.contains('presente continuo')) return [q('She ___ studying now.', 'is', 'are', 'am', 'be', 'Con she usamos is + verbo-ing.'), q('They are ___ dinner.', 'having', 'have', 'has', 'had', 'El presente continuo usa verbo-ing.')];
    if (t.contains('presente simple')) return [q('He ___ English every day.', 'studies', 'study', 'studying', 'studied', 'Con he agregamos -s/-es; study cambia a studies.'), q('___ you work here?', 'Do', 'Does', 'Are', 'Is', 'Do forma preguntas con you.')];
    if (t.contains('clima') || t.contains('temperatura')) return [q('It ___ sunny today.', 'is', 'are', 'am', 'be', 'Para describir el clima usamos it is.'), q('It is ___ than yesterday.', 'colder', 'cold', 'coldest', 'more cold', 'Para comparar cold usamos colder than.')];
    if (t.contains('comparar')) return [q('This bag is cheaper ___ that one.', 'than', 'then', 'that', 'as', 'Than introduce el segundo elemento de la comparación.')];
    if (t.contains('correo') || t.contains('email')) return [q('Please find the file ___ .', 'attached', 'attach', 'attaching', 'attaches', 'Attached indica que el archivo va incluido en el correo.')];
    if (t.contains('emocion')) return [q('I ___ nervous before exams.', 'feel', 'feels', 'feeling', 'felted', 'Con I usamos feel para expresar cómo nos sentimos.')];
    if (t.contains('pago') || t.contains('precio') || t.contains('tienda') || t.contains('devoluciones')) return [q('How much ___ these shoes?', 'are', 'is', 'am', 'be', 'Shoes es plural, por eso usamos are.'), q('Can I pay ___ credit card?', 'by', 'in', 'at', 'on', 'Usamos by credit card para indicar el método de pago.')];
    if (t.contains('viaje') || t.contains('aeropuerto') || t.contains('hotel')) return [q('My flight ___ delayed.', 'is', 'are', 'am', 'be', 'Flight es singular, por eso usamos is.'), q('Where ___ the boarding gate?', 'is', 'are', 'am', 'be', 'Where is pregunta por la ubicación de algo singular.')];
    if (t.contains('tecnologia') || t.contains('internet') || t.contains('dispositivo') || t.contains('seguridad')) return [q('You should ___ your password.', 'protect', 'protects', 'protecting', 'protected', 'Después de should usamos el verbo base.'), q('I ___ the file yesterday.', 'downloaded', 'download', 'downloads', 'downloading', 'Yesterday indica pasado simple.')];
    if (t.contains('animal') || t.contains('salvaje') || t.contains('domestico')) return [q('A bird ___ fly.', 'can', 'cans', 'is', 'does', 'Can expresa habilidad y no cambia con la tercera persona.'), q('Dogs ___ friendly animals.', 'are', 'is', 'am', 'be', 'Dogs es plural, por eso usamos are.')];
    if (t.contains('casa') || t.contains('hogar') || t.contains('mueble') || t.contains('habitacion')) return [q('There ___ a lamp in my room.', 'is', 'are', 'am', 'be', 'There is se usa con un sustantivo singular.'), q('There ___ two chairs in the kitchen.', 'are', 'is', 'am', 'be', 'There are se usa con sustantivos plurales.')];
    if (t.contains('saludo') || t.contains('presentarse') || t.contains('nacionalidad')) return [q('I ___ from Mexico.', 'am', 'is', 'are', 'be', 'Con I usamos am.'), q('She ___ Mexican.', 'is', 'are', 'am', 'be', 'Con she usamos is.')];
    if (t.contains('hora') || t.contains('fecha') || t.contains('numero')) return [q('The class starts ___ 8:00.', 'at', 'in', 'on', 'by', 'At se utiliza con horas exactas.'), q('My birthday is ___ June.', 'in', 'on', 'at', 'by', 'In se utiliza con meses y años.')];
    if (t.contains('salud') || t.contains('sintoma') || t.contains('recomendacion')) return [q('You should ___ some rest.', 'get', 'gets', 'getting', 'got', 'Should va seguido del verbo base.'), q('I ___ a headache.', 'have', 'has', 'having', 'am', 'Usamos have para expresar que tenemos un síntoma.')];
    if (t.contains('negociacion')) return [q('Could we ___ on Friday?', 'meet', 'meets', 'meeting', 'met', 'Después de could usamos el verbo base.'), q('We are ___ to the proposal.', 'open', 'opens', 'opening', 'opened', 'Be open to es una expresión para mostrar disposición.')];
    if (t.contains('conectores')) return [q('I was tired; ___, I finished my work.', 'however', 'because', 'unless', 'during', 'However introduce un contraste entre dos ideas.')];
    return [q('This expression ___ useful in conversation.', 'is', 'are', 'am', 'be', 'Expression es singular, por eso usamos is.'), q('You should ___ the new phrase.', 'use', 'uses', 'using', 'used', 'Después de should siempre usamos el verbo en su forma base.')];
  }
}
