import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/player.dart';

class JogadorService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> salvarJogador(Player jogador) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    await _firestore
        .collection('jogadores')
        .doc(user.uid)
        .set(jogador.toMap());
  }

  Future<Player?> carregarJogador() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final doc = await _firestore
        .collection('jogadores')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Player.fromMap(doc.data()!);
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

  Future<bool> criarJogadorSeNaoExistir(Player jogador) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final docRef =
        _firestore.collection('jogadores').doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(jogador.toMap());
      return true;
    }

    return false;
  }
}