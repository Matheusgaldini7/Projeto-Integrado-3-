import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Cadastro
  Future<UserCredential> cadastrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'A senha deve conter pelo menos 6 caracteres';
      }
      if (e.code == 'email-already-in-use') {
        throw 'Este e-mail já está cadastrado em outra conta';
      }
      if (e.code == 'invalid-email') {
        throw 'O formato do e-mail digitado é inválido';
      }
      throw 'Erro ao criar conta no campus';
    } catch (e) {
      throw 'Ocorreu um erro inesperado no registro';
    }
  }

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