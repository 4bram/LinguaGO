import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lingua_go/components/theme_app.dart';
import 'package:lingua_go/models/unidad_model.dart';
import 'package:lingua_go/models/contenido_capitulos.dart';
import 'package:lingua_go/providers/practica_provider.dart';
import 'package:lingua_go/providers/sesion_provider.dart';
import 'package:lingua_go/providers/unidades_provider.dart';
import 'package:provider/provider.dart';

class PracticaScreen extends StatelessWidget {
  const PracticaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PracticaProvider(),
      child: const _PracticaVista(),
    );
  }
}

class _PracticaVista extends StatefulWidget {
  const _PracticaVista();

  @override
  State<_PracticaVista> createState() => _PracticaVistaState();
}

class _PracticaVistaState extends State<_PracticaVista> {
  late PracticaProvider _p;
  final _random = Random();
  final _tts = FlutterTts();
  final _audio = AudioPlayer();
  final _respuesta = TextEditingController();
  late String _unidadId;
  late String _tipo;
  int? _capituloIndex;
  ContenidoCapitulo? _contenido;
  UnidadModel? _unidad;
  bool _vozLista = false;

  List<Map<String, String>> get _preguntas => _p.preguntas;
  int get _indice => _p.indice;
  int get _aciertos => _p.aciertos;
  int? get _seleccion => _p.seleccion;
  bool get _respondida => _p.respondida;
  bool get _terminada => _p.terminada;

  static const _gramatica = <Map<String, String>>[
    {'q': 'She ___ to school every day.', 'a': 'goes', 'b': 'go', 'c': 'going', 'd': 'gone', 'why': 'Con he, she e it agregamos -s o -es en presente simple.'},
    {'q': 'They ___ watching a movie now.', 'a': 'are', 'b': 'is', 'c': 'am', 'd': 'be', 'why': 'Usamos are con they en presente continuo.'},
    {'q': 'I ___ my grandmother yesterday.', 'a': 'visited', 'b': 'visit', 'c': 'visits', 'd': 'visiting', 'why': 'Yesterday indica pasado simple: visit se convierte en visited.'},
    {'q': 'There ___ two books on the table.', 'a': 'are', 'b': 'is', 'c': 'am', 'd': 'be', 'why': 'There are se utiliza con sustantivos plurales.'},
    {'q': 'He doesn’t ___ coffee.', 'a': 'like', 'b': 'likes', 'c': 'liking', 'd': 'liked', 'why': 'Después de doesn’t usamos el verbo en forma base.'},
    {'q': 'We ___ going to travel next week.', 'a': 'are', 'b': 'is', 'c': 'am', 'd': 'was', 'why': 'Going to usa el verbo to be; con we corresponde are.'},
    {'q': 'This is ___ apple.', 'a': 'an', 'b': 'a', 'c': 'the', 'd': 'some', 'why': 'An se usa antes de un sonido vocálico.'},
    {'q': 'My brother is taller ___ me.', 'a': 'than', 'b': 'that', 'c': 'then', 'd': 'as', 'why': 'Than introduce el segundo elemento de una comparación.'},
    {'q': '___ you speak English?', 'a': 'Do', 'b': 'Does', 'c': 'Are', 'd': 'Is', 'why': 'Do acompaña a you para formar preguntas en presente simple.'},
    {'q': 'I have lived here ___ 2020.', 'a': 'since', 'b': 'for', 'c': 'during', 'd': 'from', 'why': 'Since se usa con el punto de inicio de un periodo.'},
    {'q': 'If it rains, we ___ at home.', 'a': 'will stay', 'b': 'stayed', 'c': 'stays', 'd': 'staying', 'why': 'En el primer condicional: if + presente, will + verbo base.'},
    {'q': 'This is the ___ film I have ever seen.', 'a': 'best', 'b': 'better', 'c': 'good', 'd': 'well', 'why': 'Best es el superlativo irregular de good.'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _p = context.read<PracticaProvider>();
    if (_unidad != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _unidadId = args['unidadId']?.toString() ?? '';
      _tipo = args['tipo']?.toString() ?? 'quiz';
      final rawIndex = args['capituloIndex'];
      _capituloIndex = rawIndex is int ? rawIndex : int.tryParse(rawIndex?.toString() ?? '');
    } else {
      _unidadId = args?.toString() ?? '';
      _tipo = 'quiz';
    }
    _unidad = context.read<UnidadesProvider>().m_porId(_unidadId);
    if (_unidad != null) _preparar();
  }

  Future<void> _prepararVoz() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.43);
      await _tts.setPitch(1.0);
      _vozLista = true;
    } catch (_) {
      _vozLista = false;
    }
  }

  String _nombreAudio(String texto) {
    return texto.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  Future<void> _hablar(String texto) async {
    final archivo = '${_nombreAudio(texto)}.mp3';
    try {
      await rootBundle.load('assets/audios/$archivo');
      await _tts.stop();
      await _audio.stop();
      await _audio.play(AssetSource('audios/$archivo'));
      return;
    } catch (_) {
    }
    try {
      if (!_vozLista) await _prepararVoz();
      await _audio.stop();
      await _tts.stop();
      await _tts.speak(texto);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró un MP3 y la voz del dispositivo no está disponible.')),
        );
      }
    }
  }

  void _preparar() {
    final unidad = _unidad!;
    _contenido = _capituloIndex == null ? null : ContenidoCapitulo.crear(unidad, _capituloIndex!);
    final baseVocab = _capituloIndex != null
        ? (_contenido?.vocabulario ?? const <Map<String, String>>[])
        : unidad.vocabulario;
    final vocab = List<Map<String, String>>.from(baseVocab)..shuffle(_random);
    final cantidad = min(10, vocab.length);
    List<Map<String, String>> preguntas;
    if (_tipo == 'gramatica') {
      final origen = _capituloIndex != null ? (_contenido?.gramatica ?? const <Map<String, String>>[]) : _gramatica;
      final lista = List<Map<String, String>>.from(origen)..shuffle(_random);
      preguntas = lista.take(min(10, lista.length)).toList();
    } else if (_tipo == 'evaluacion' && _contenido != null) {
      final palabras = vocab.take(min(5, vocab.length)).toList();
      final reglas = List<Map<String, String>>.from(_contenido!.gramatica)..shuffle(_random);
      preguntas = [...palabras, ...reglas.take(3)]..shuffle(_random);
    } else if (_tipo == 'evaluacion_unidad') {
      final vocabTodo = <String, Map<String, String>>{};
      final gramTodo = <Map<String, String>>[];
      for (int i = 0; i < unidad.capitulos.length; i++) {
        final c = ContenidoCapitulo.crear(unidad, i);
        for (final v in c.vocabulario) {
          final en = v['en'] ?? '';
          if (en.isNotEmpty) vocabTodo.putIfAbsent(en, () => v);
        }
        gramTodo.addAll(c.gramatica);
      }
      final vocabLista = vocabTodo.values.toList()..shuffle(_random);
      gramTodo.shuffle(_random);
      preguntas = [
        ...vocabLista.take(min(8, vocabLista.length)),
        ...gramTodo.take(min(4, gramTodo.length)),
      ]..shuffle(_random);
    } else {
      preguntas = vocab.take(cantidad).toList();
    }
    _p.m_inicia(preguntas);
    _prepararVoz();
    if (_tipo == 'escucha' && _preguntas.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hablar(_preguntas.first['en'] ?? '');
      });
    }
  }

  String get _titulo {
    switch (_tipo) {
      case 'escucha': return 'Entrenamiento auditivo';
      case 'gramatica': return 'Reto de gramática';
      case 'escritura': return 'Práctica de escritura';
      case 'leccion': return 'Lección del capítulo';
      case 'evaluacion': return 'Evaluación del capítulo';
      case 'evaluacion_unidad': return 'Evaluación final de la unidad';
      default: return 'Prueba de vocabulario';
    }
  }

  List<String> _opciones(Map<String, String> p) {
    if (p.containsKey('a')) {
      final opciones = [p['a']!, p['b']!, p['c']!, p['d']!]..shuffle(_random);
      return opciones;
    }
    final correcta = _tipo == 'escucha' ? p['es']! : p['en']!;
    final campo = _tipo == 'escucha' ? 'es' : 'en';
    final otras = (_contenido?.vocabulario.isNotEmpty == true ? _contenido!.vocabulario : _unidad!.vocabulario)
        .map((e) => e[campo] ?? '')
        .where((e) => e.isNotEmpty && e != correcta)
        .toSet()
        .toList()..shuffle(_random);
    final opciones = <String>[correcta, ...otras.take(3)]..shuffle(_random);
    return opciones;
  }

  bool _esCorrecta(int opcion) {
    final p = _preguntas[_indice];
    final correcta = p.containsKey('a')
        ? p['a']
        : (_tipo == 'escucha' ? p['es'] : p['en']);
    return _opcionesActuales[opcion] == correcta;
  }

  List<String> get _opcionesActuales {
    final p = _preguntas[_indice];
    return _p.opcionesCache ??= _opciones(p);
  }

  void _responder(int opcion) {
    if (_respondida) return;
    _p.m_responde(opcion, _esCorrecta(opcion));
  }

  void _comprobarEscritura() {
    if (_respondida) return;
    final esperada = (_preguntas[_indice]['en'] ?? '').toLowerCase().trim();
    final escrita = _respuesta.text.toLowerCase().trim()
        .replaceAll(RegExp(r'[.!?,]'), '');
    final correcta = escrita == esperada.replaceAll(RegExp(r'[.!?,]'), '');
    _p.m_respondeEscritura(correcta);
  }

  void _siguiente() {
    if (_p.m_siguiente()) {
      _guardarProgreso();
      return;
    }
    _respuesta.clear();
    if (_tipo == 'escucha') _hablar(_preguntas[_indice]['en'] ?? '');
  }

  void _guardarProgreso() {
    if (_p.guardado || _unidad == null) return;
    _p.guardado = true;
    final porcentaje = (_aciertos / _preguntas.length * 100).round();
    final up = context.read<UnidadesProvider>();
    final unidad = _unidad!;

    if (_tipo == 'evaluacion_unidad') {
      up.m_registraEvaluacionUnidad(
        unidad,
        porcentaje,
        nombre: context.read<SesionProvider>().nombre,
      );
      return;
    }

    final cap = _capituloIndex;
    if (cap == null) return;

    if (_tipo == 'evaluacion') {
      up.m_registraEvaluacionCapitulo(unidad, cap, porcentaje);
      return;
    }

    if (porcentaje >= UnidadesProvider.umbral &&
        (_tipo == 'escucha' || _tipo == 'gramatica' || _tipo == 'escritura')) {
      up.m_completaActividad(unidad, cap, _tipo);
    }
  }

  Widget _bloqueo(String mensaje) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 72, color: ThemeApp.lila),
              const SizedBox(height: 14),
              Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _audio.dispose();
    _respuesta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<PracticaProvider>();
    if (_unidad == null || (_preguntas.isEmpty && _tipo != 'leccion')) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('No hay contenido para esta actividad.')));
    }

    final up = context.watch<UnidadesProvider>();
    if (_tipo == 'evaluacion' && _capituloIndex != null &&
        !up.m_materialCompleto(_unidad!, _capituloIndex!)) {
      return _bloqueo('Para presentar la evaluación del capítulo termina antes la lección, '
          'las tarjetas, la escucha, la gramática y la escritura.');
    }
    if (_tipo == 'evaluacion_unidad' && !up.m_capitulosCompletos(_unidad!)) {
      return _bloqueo('La evaluación final se abre cuando completes todos los capítulos '
          'de la unidad (material + evaluación del capítulo con 70 % o más).');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_contenido == null ? _titulo : '${_contenido!.titulo} · $_titulo'),
        backgroundColor: ThemeApp.morado,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: _terminada ? _resultado() : (_tipo == 'leccion' ? _leccion() : _actividad()),
            ),
          ),
        ),
      ),
    );
  }

  void _abrirTipoDesdeLeccion(String tipo) {
    Navigator.pushReplacementNamed(context, '/practica', arguments: {
      'unidadId': _unidadId,
      'tipo': tipo,
      'capituloIndex': _capituloIndex,
    });
  }

  Widget _leccion() {
    final c = _contenido;
    if (c == null) return const Center(child: Text('No se encontró el contenido del capítulo.'));
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [ThemeApp.morado, ThemeApp.lila]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('OBJETIVO DEL CAPÍTULO', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(c.objetivo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Explicación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        Text(c.explicacion, style: const TextStyle(height: 1.45)),
        const SizedBox(height: 20),
        const Text('Vocabulario del tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final p in c.vocabulario)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(p['en'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(p['es'] ?? ''),
            trailing: IconButton(
              tooltip: 'Escuchar pronunciación',
              onPressed: () => _hablar(p['en'] ?? ''),
              icon: const Icon(Icons.volume_up, color: ThemeApp.morado),
            ),
          ),
        const SizedBox(height: 12),
        const Text('Ejemplos en contexto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final ejemplo in c.ejemplos)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: ThemeApp.lila.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)),
            child: Text(ejemplo, style: const TextStyle(height: 1.35)),
          ),
        const SizedBox(height: 14),
        const Text('Practica lo aprendido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _accionLeccion('Vocabulario', Icons.style, 'quiz'),
          _accionLeccion('Escucha', Icons.headphones, 'escucha'),
          _accionLeccion('Gramática', Icons.spellcheck, 'gramatica'),
          _accionLeccion('Escritura', Icons.edit, 'escritura'),
          _accionLeccion('Evaluación', Icons.quiz, 'evaluacion'),
        ]),
        const SizedBox(height: 8),
        _botonCompletarLeccion(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _botonCompletarLeccion() {
    final cap = _capituloIndex;
    if (cap == null || _unidad == null) return const SizedBox.shrink();
    final hecha = context.watch<UnidadesProvider>().m_actividadesCap(_unidad!, cap).contains('leccion');
    return FilledButton.icon(
      onPressed: hecha
          ? null
          : () {
              context.read<UnidadesProvider>().m_completaActividad(_unidad!, cap, 'leccion');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Lección completada!'), duration: Duration(seconds: 2)),
              );
            },
      icon: Icon(hecha ? Icons.check_circle : Icons.task_alt),
      label: Text(hecha ? 'Lección completada' : 'Marcar lección como completada'),
    );
  }

  Widget _accionLeccion(String texto, IconData icono, String tipo) {
    return FilledButton.tonalIcon(
      onPressed: () => _abrirTipoDesdeLeccion(tipo),
      icon: Icon(icono, size: 17),
      label: Text(texto),
    );
  }

  Widget _actividad() {
    final p = _preguntas[_indice];
    final escucha = _tipo == 'escucha';
    final escritura = _tipo == 'escritura';
    final gramatica = _tipo == 'gramatica' || p.containsKey('a');
    final textoEscrito = _respuesta.text.toLowerCase().trim().replaceAll(RegExp(r'[.!?,]'), '');
    final correcto = escritura
        ? textoEscrito == (p['en'] ?? '').toLowerCase().trim().replaceAll(RegExp(r'[.!?,]'), '')
        : (_seleccion != null && _esCorrecta(_seleccion!));

    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: IntrinsicHeight(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_contenido != null) ...[
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: ThemeApp.lila.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_contenido!.objetivo, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text(_contenido!.explicacion, style: const TextStyle(fontSize: 12)),
              if (_contenido!.ejemplos.isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(_contenido!.ejemplos.first, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ]),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pregunta ${_indice + 1} de ${_preguntas.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('Aciertos: $_aciertos', style: const TextStyle(color: ThemeApp.morado, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: (_indice + (_respondida ? 1 : 0)) / _preguntas.length, minHeight: 9, color: ThemeApp.lila),
        ),
        const SizedBox(height: 28),
        if (escucha) ...[
          const Icon(Icons.headphones, size: 54, color: ThemeApp.morado),
          const SizedBox(height: 10),
          const Text('Escucha la palabra y selecciona su significado', textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Center(child: OutlinedButton.icon(onPressed: () => _hablar(p['en'] ?? ''), icon: const Icon(Icons.volume_up), label: const Text('Escuchar otra vez'))),
        ] else if (escritura) ...[
          const Text('Escribe en inglés la palabra correspondiente:', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(p['es'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: _respuesta,
            enabled: !_respondida,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Escribe tu respuesta', border: OutlineInputBorder()),
            onSubmitted: (_) => _comprobarEscritura(),
          ),
          const SizedBox(height: 12),
          if (!_respondida) ElevatedButton(onPressed: _comprobarEscritura, child: const Text('Comprobar respuesta')),
        ] else ...[
          Text(gramatica ? 'Completa correctamente la oración:' : '¿Cómo se dice en inglés?', textAlign: TextAlign.center),
          const SizedBox(height: 22),
          Text(gramatica ? p['q']! : p['es']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        ],
        if (!escritura) ...[
          const SizedBox(height: 22),
          for (int i = 0; i < _opcionesActuales.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
                  side: BorderSide(color: _respondida && _esCorrecta(i) ? Colors.green : (_seleccion == i ? Colors.red : Colors.black12), width: 1.5),
                  backgroundColor: _respondida && _esCorrecta(i) ? Colors.green.withValues(alpha: .10) : null,
                ),
                onPressed: _respondida ? null : () => _responder(i),
                child: Text(_opcionesActuales[i], style: const TextStyle(fontSize: 16)),
              ),
            ),
        ],
        if (_respondida) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: correcto ? Colors.green.withValues(alpha: .10) : Colors.orange.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
            child: Text(
              correcto ? '¡Muy bien! Respuesta correcta.' : 'Respuesta correcta: ${gramatica ? p['a'] : p['en']}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (gramatica && p['why'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(p['why']!)),
          const Spacer(),
          SizedBox(height: 50, child: ElevatedButton(onPressed: _siguiente, style: ElevatedButton.styleFrom(backgroundColor: ThemeApp.morado, foregroundColor: Colors.white), child: Text(_indice + 1 == _preguntas.length ? 'Ver resultados' : 'Siguiente'))),
        ] else
          const Spacer(),
      ],
    )),
        ),
      ),
    );
  }

  Widget _resultado() {
    final porcentaje = (_aciertos / _preguntas.length * 100).round();
    final mensaje = porcentaje >= 90 ? '¡Excelente trabajo!' : porcentaje >= 70 ? '¡Vas muy bien!' : porcentaje >= 50 ? 'Buen intento, sigue practicando.' : 'Cada intento cuenta. ¡Inténtalo otra vez!';
    final up = context.watch<UnidadesProvider>();
    final aprobado = porcentaje >= UnidadesProvider.umbral;
    final String nota;
    Map<String, dynamic>? guardado;
    if (_tipo == 'evaluacion_unidad') {
      nota = aprobado
          ? '¡Unidad aprobada! Se desbloqueó la siguiente unidad.'
          : 'Necesitas 70 % para aprobar la unidad. Repasa los capítulos e inténtalo otra vez.';
      guardado = up.m_evalUnidad(_unidad!);
    } else if (_tipo == 'evaluacion') {
      nota = aprobado
          ? '¡Capítulo completado!'
          : 'Necesitas 70 % para completar el capítulo. Repasa el tema e inténtalo otra vez.';
      if (_capituloIndex != null) guardado = up.m_evalCapitulo(_unidad!, _capituloIndex!);
    } else if (_capituloIndex != null && _tipo != 'quiz') {
      nota = aprobado
          ? 'Actividad registrada en el avance de tu capítulo.'
          : 'Necesitas 70 % para registrar esta actividad en tu capítulo.';
    } else {
      nota = 'Práctica libre: no cuenta para tu avance.';
    }
    final detalle = guardado == null
        ? ''
        : 'Mejor resultado: ${guardado['mejor']} % · Intentos: ${guardado['intentos']}';
    final certUrl = '${up.m_evalUnidad(_unidad!)?['certificadoUrl'] ?? ''}';
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(porcentaje >= 70 ? Icons.emoji_events : Icons.school, size: 86, color: ThemeApp.lila),
        const SizedBox(height: 18),
        Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text('$_aciertos de ${_preguntas.length} respuestas correctas', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 18),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: porcentaje / 100, minHeight: 12, color: ThemeApp.morado)),
        const SizedBox(height: 8),
        Text('$porcentaje% de precisión', textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(nota, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (detalle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(detalle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
        if (_tipo == 'evaluacion_unidad' && aprobado) ...[
          const SizedBox(height: 10),
          if (up.generandoCertificado)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Generando tu certificado…', style: TextStyle(fontSize: 12)),
              ],
            )
          else if (certUrl.isNotEmpty)
            const Text('🎓 Tu certificado está en Perfil → Mis certificados',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: ThemeApp.morado, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
          child: const Text('Volver a la unidad'),
        ),
        TextButton(
          onPressed: () {
            _respuesta.clear();
            _p.m_reinicia(_random);
            if (_tipo == 'escucha') _hablar(_preguntas.first['en'] ?? '');
          },
          child: const Text('Repetir actividad'),
        ),
      ],
    ),
        ),
      ),
    );
  }
}
