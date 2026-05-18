import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Login email/senha
  Future<UserCredential> loginEmailSenha({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {

      if (e.code == 'invalid-credential') {
        throw 'Email ou senha incorretos';
      }

      throw 'Erro ao fazer login';
    }
  }

  // Login google
  Future<UserCredential?> loginGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);

    } catch (e) {
      throw 'Erro ao fazer login com Google';
    }
  }
}