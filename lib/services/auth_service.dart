import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'jogador_service.dart';
import '../models/player.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final JogadorService _jogadorService = JogadorService();

  // CADASTRO EMAIL/SENHA
  Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await _jogadorService.criarJogadorSeNaoExistir(
        Player(
          nickname: '',
          genero: '',
        ),
      );

      return cred;
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

  // LOGIN EMAIL/SENHA
  Future<UserCredential> login({
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

  // LOGIN GOOGLE
  Future<UserCredential?> loginGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();
          
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);
      await _jogadorService.criarJogadorSeNaoExistir(
        Player(
          nickname: '',
          genero: '',
        ),
      );

      return userCredential;

    } catch (e) {
      throw 'Erro ao fazer login com Google';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}