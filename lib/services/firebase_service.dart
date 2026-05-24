import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // ── Salva perfil do usuário ──────────────────────────────────────────────
  static Future<void> salvarUsuario(String uid, String nome, String genero) async {
    await _db.collection('usuarios').doc(uid).set({
      'nome': nome,
      'genero': genero,
      'criadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Salva estado do jogo ─────────────────────────────────────────────────
  static Future<void> salvarJogador(String uid, Player player) async {
    await _db.collection('jogadores').doc(uid).set(
      player.toMap()..addAll({'atualizadoEm': FieldValue.serverTimestamp()}),
      SetOptions(merge: true),
    );
  }

  // ── Carrega estado do jogo ───────────────────────────────────────────────
  static Future<Player?> carregarJogador(String uid) async {
    final doc = await _db.collection('jogadores').doc(uid).get();
    if (!doc.exists) return null;
    return Player.fromMap(doc.data()!);
  }

  // ── Registra fase vencida ────────────────────────────────────────────────
  static Future<void> registrarFase(String uid, String faseId) async {
    await _db
        .collection('progresso')
        .doc(uid)
        .collection('fases')
        .doc(faseId)
        .set({
      'vencida': true,
      'vencidaEm': FieldValue.serverTimestamp(),
    });
  }

  // ── Atualiza ranking ─────────────────────────────────────────────────────
  static Future<void> atualizarRanking(
      String uid, String nome, int fasesVencidas) async {
    await _db.collection('ranking').doc(uid).set({
      'nome': nome,
      'fasesVencidas': fasesVencidas,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Busca ranking geral (top 10) ─────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> buscarRanking() async {
    final snapshot = await _db
        .collection('ranking')
        .orderBy('fasesVencidas', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}