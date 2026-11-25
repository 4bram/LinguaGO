import 'package:firebase_auth/firebase_auth.dart';

String traduceErrorAuth(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Correo o contrasena incorrectos';
    case 'email-already-in-use':
      return 'Ese correo ya esta registrado';
    case 'weak-password':
      return 'La contrasena es debil (min 6 caracteres)';
    case 'invalid-email':
      return 'Correo no valido';
    case 'user-disabled':
      return 'Cuenta deshabilitada';
    case 'too-many-requests':
      return EmailAuth.mensajeDemasiadosIntentos;
    case 'network-request-failed':
      return 'Sin internet';
    case 'account-exists-with-different-credential':
      return 'Ya existe una cuenta con ese correo (otro metodo)';
    case 'canceled':
    case 'cancelled-popup-request':
    case 'popup-closed-by-user':
    case 'web-context-canceled':
      return 'Inicio de sesion cancelado';
    default:
      return 'Error: ${e.message ?? e.code}';
  }
}

class EmailAuth {
  static const String mensajeDemasiadosIntentos = 'Muchos intentos, espera un poco';

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
      return 'Error: $e';
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
      return 'Error: $e';
    }
  }

  Future<String?> m_reenviaVerificacion() async {
    try {
      final usuario = _firebaseAuth.currentUser;
      if (usuario == null) return 'No hay sesion activa';
      await usuario.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> m_recuperaPassword(String correo) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'Error: $e';
    }
  }
}
