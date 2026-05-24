import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  Future<UserCredential> cadastrar({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw 'Senha muito fraca (mínimo 6 caracteres)';
      if (e.code == 'email-already-in-use') throw 'Este e-mail já está cadastrado';
      if (e.code == 'invalid-email') throw 'E-mail inválido';
      throw 'Erro ao criar conta';
    }
  }

  Future<UserCredential> login({
    required String email,
    required String senha,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') throw 'E-mail ou senha incorretos';
      throw 'Erro ao fazer login';
    }
  }



  Future<void> logout() => _auth.signOut();
}
