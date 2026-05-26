import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class PlayerStorage {
  static const _key = 'journey_degree_player';

  static Future<void> salvar(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(player.toMap()));
  }

  static Future<Player?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return Player.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
