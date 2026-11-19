import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingua_go/config/email_auth.dart';
import 'package:lingua_go/config/firestore_usuario.dart';
import 'package:lingua_go/config/social_auth.dart';
import 'package:lingua_go/config/storage_service.dart';

class SesionProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailAuth _emailAuth = EmailAuth();
  final SocialAuth _socialAuth = SocialAuth();
  final StorageService _storage = StorageService();

  final FirestoreUsuario _fsUsuario = FirestoreUsuario();

  User? usuario;

  bool esAdmin = false;
  String? _uidAdmin;
  bool cargando = false;
  bool bienvenidaPendiente = false;
  bool subiendoFoto = false;
  StreamSubscription<User?>? _sub;

  SesionProvider() {
    usuario = _auth.currentUser;
    _cargaAdmin(usuario);
    _cargaBienvenida(usuario);
    _sub = _auth.userChanges().listen((u) {
      usuario = u;
      notifyListeners();
      _cargaAdmin(u);
      _cargaBienvenida(u);
    });
  }

  String? _bienvenidaVistaUid;

  String _claveBienvenida(String uid) => 'bienvenida_pendiente_$uid';

  Future<void> _cargaBienvenida(User? u) async {
    if (u == null) {
      if (bienvenidaPendiente) {
        bienvenidaPendiente = false;
        notifyListeners();
      }
      return;
    }
    if (u.uid == _bienvenidaVistaUid) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardada = prefs.getBool(_claveBienvenida(u.uid)) ?? false;
      if (guardada != bienvenidaPendiente && guardada) {
        bienvenidaPendiente = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _marcaBienvenida() async {
    bienvenidaPendiente = true;
    notifyListeners();
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_claveBienvenida(uid), true);
    } catch (_) {}
  }

  Future<void> _cargaAdmin(User? u) async {
    if (u == null) {
      _uidAdmin = null;
      if (esAdmin) {
        esAdmin = false;
        notifyListeners();
      }
      return;
    }
    if (_uidAdmin == u.uid) return;
    _uidAdmin = u.uid;
    final valor = await _fsUsuario.m_esAdmin(u.uid);
    if (_uidAdmin != u.uid) return;
    if (valor != esAdmin) {
      esAdmin = valor;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get esCorreo =>
      usuario?.providerData.any((p) => p.providerId == 'password') ?? false;

  bool get correoVerificado =>
      usuario != null && (!esCorreo || usuario!.emailVerified);

  String? get fotoUrl => usuario?.photoURL;

  String get nombreCorto {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? '' : partes.first;
  }

  String get correo => usuario?.email ?? '';

  String get nombre {
    final n = usuario?.displayName;
    if (n != null && n.trim().isNotEmpty) return n;
    return correo.isNotEmpty ? correo.split('@').first : 'Usuario';
  }

  String get proveedor {
    final ids = usuario?.providerData.map((p) => p.providerId).toList() ?? [];
    if (ids.contains('google.com')) return 'Google';
    if (ids.contains('github.com')) return 'GitHub';
    return 'Correo y contraseña';
  }

  Future<String?> _ejecuta(Future<String?> Function() accion) async {
    cargando = true;
    notifyListeners();
    final resultado = await accion();
    cargando = false;
    notifyListeners();
    return resultado;
  }

  Future<String?> m_login(String correo, String pass) =>
      _ejecuta(() => _emailAuth.m_loginUser(user: correo, pass: pass));

  Future<String?> m_registra(String nombre, String correo, String pass) async {
    final error = await _ejecuta(
        () => _emailAuth.m_creaUsuario(nombre: nombre, user: correo, pass: pass));
    if (error == null) await _marcaBienvenida();
    return error;
  }

  Future<String?> m_loginGoogle() => _conDeteccionNueva(_socialAuth.m_loginGoogle);

  Future<String?> m_loginGithub() => _conDeteccionNueva(_socialAuth.m_loginGithub);

  Future<String?> _conDeteccionNueva(Future<String?> Function() accion) async {
    final error = await _ejecuta(accion);
    if (error == null) {
      final m = _auth.currentUser?.metadata;
      final c = m?.creationTime;
      final l = m?.lastSignInTime;
      if (c != null && l != null && l.difference(c).inSeconds.abs() < 15) {
        await _marcaBienvenida();
      }
    }
    return error;
  }

  Future<void> m_bienvenidaHecha() async {
    final uid = _auth.currentUser?.uid;
    _bienvenidaVistaUid = uid;
    bienvenidaPendiente = false;
    notifyListeners();
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_claveBienvenida(uid));
    } catch (_) {}
  }

  Future<String?> m_reenviaVerificacion() =>
      _ejecuta(_emailAuth.m_reenviaVerificacion);

  Future<String?> m_recuperaPassword(String correo) =>
      _ejecuta(() => _emailAuth.m_recuperaPassword(correo));

  Future<void> m_recargaUsuario() async {
    try {
      await _auth.currentUser?.reload();
    } catch (_) {}
    usuario = _auth.currentUser;
    notifyListeners();
  }

  Future<void> m_cerrarSesion() async {
    bienvenidaPendiente = false;
    await _socialAuth.m_cerrarGoogle();
    await _auth.signOut();
  }

  Future<String?> m_cambiaFoto() async {
    if (!esCorreo) {
      return 'La foto de perfil solo se puede cambiar en cuentas de correo';
    }
    try {
      final img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (img == null) return null;
      subiendoFoto = true;
      notifyListeners();
      final bytes = await img.readAsBytes();
      final url = await _storage.m_subirFotoPerfil(usuario!.uid, bytes);
      await usuario!.updatePhotoURL(url);
      await usuario!.reload();
      usuario = _auth.currentUser;
      return null;
    } catch (e) {
      return 'No se pudo actualizar la foto: $e';
    } finally {
      subiendoFoto = false;
      notifyListeners();
    }
  }
}
