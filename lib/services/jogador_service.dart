import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/jogador_model.dart';

class JogadorService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> criarJogador(Jogador jogador) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    await _firestore
        .collection('jogadores')
        .doc(user.uid)
        .set(jogador.toMap());
  }

  Future<bool> jogadorExiste() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final doc = await _firestore
        .collection('jogadores')
        .doc(user.uid)
        .get();

    return doc.exists;
  }
}