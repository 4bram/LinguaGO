import 'package:firebase_auth/firebase_auth.dart';

/// Se traduce los menssjes de error de firebase a español,para debuggear mas comodo.
String traduceErrorAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Correo o contraseña incorrectos';
    case 'email-already-in-use':
      return 'Ese correo ya está registrado';
    case 'weak-password':
      return 'La contraseña es muy débil (mínimo 6 caracteres)';
    case 'invalid-email':
      return 'El correo no es válido';
    case 'user-disabled':
      return 'Esta cuenta fue deshabilitada';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento';
    case 'network-request-failed':
      return 'Sin conexión a internet';
    case 'account-exists-with-different-credential':
      return 'Ya existe una cuenta con ese correo usando otro método de acceso';
    case 'canceled':
    case 'cancelled-popup-request':
    case 'popup-closed-by-user':
    case 'web-context-canceled':
      return 'Inicio de sesión cancelado';
    default:
      return 'Error: ${e.message ?? e.code}';
  }
}


class EmailAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> m_creaUsuario({
    required String nombre,
    required String user,
    required String pass,
  }) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user,
        password: pass,
      );
      await credentials.user!.updateDisplayName(nombre);
      await credentials.user!.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<String?> m_loginUser({
    required String user,
    required String pass,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: user, password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<String?> m_reenviaVerificacion() async {
    try {
      final usuario = _firebaseAuth.currentUser;
      if (usuario == null) return 'No hay una sesión activa';
      await usuario.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  
  Future<String?> m_recuperaPassword(String correo) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }
}
