import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lingua_go/config/email_auth.dart';

class SocialAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _webClientId =
      '365349118046-8konoecqvifu4ipel6s92p6ff1sbmtua.apps.googleusercontent.com';

  Future<String?> m_loginGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return null;
      }
      final cuenta = await GoogleSignIn(
        serverClientId: _webClientId,
        scopes: ['email'],
      ).signIn();
      if (cuenta == null) return 'Inicio de sesión cancelado';

      final datos = await cuenta.authentication;
      final credencial = GoogleAuthProvider.credential(
        accessToken: datos.accessToken,
        idToken: datos.idToken,
      );
      await _auth.signInWithCredential(credencial);
      return null;
    } on FirebaseAuthException catch (e) {
      return traduceErrorAuth(e);
    } catch (e) {
      return 'No se pudo iniciar sesión con Google: $e';
    }
  }

  Future<String?> m_loginGithub() async {
    final proveedor = GithubAuthProvider();
    proveedor.addScope('user:email');
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(proveedor);
      } else {
        await _auth.signInWithProvider(proveedor);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      final mensaje = traduceErrorAuth(e);
      if (mensaje == 'Inicio de sesión cancelado') return mensaje;
      return '$mensaje\nTip: usa Chrome como navegador predeterminado.';
    } catch (e) {
      return 'No se pudo iniciar sesión con GitHub: $e';
    }
  }

  Future<void> m_cerrarGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }
}
