import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/battle_helper.dart';

class BattleActions extends StatelessWidget {
  final Player player;
  final BattleHelper battle;
  final VoidCallback onAtacar;
  final void Function(String nomeItem) onUsarItem;
  final VoidCallback onFugir;

  const BattleActions({
    super.key,
    required this.player,
    required this.battle,
    required this.onAtacar,
    required this.onUsarItem,
    required this.onFugir,
  });

  @override
  Widget build(BuildContext context) {
    final itens = player.inventario
        .where((i) => catalogoItens.containsKey(i))
        .toSet()
        .toList();

    return Column(children: [
      _btn('⚔️ Atacar', const Color(0xFF5040B0), Colors.white, onAtacar),
      const SizedBox(height: 6),
      ...itens.map((nome) {
        final item = catalogoItens[nome]!;
        final ok = battle.itemDisponivel(nome);
        final faltam = battle.turnosParaItem(nome);
        final label = ok
            ? '${item.emoji} ${item.nome} — ${item.descricao}'
            : '${item.emoji} ${item.nome} (cooldown: $faltam turnos)';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: ok ? () => onUsarItem(nome) : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 11, horizontal: 12),
              decoration: BoxDecoration(
                color: ok
                    ? const Color(0xFF1A3010)
                    : const Color(0xFF374151),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ok
                      ? const Color(0xFF48D058)
                      : const Color(0xFF374151),
                ),
              ),
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: ok
                          ? const Color(0xFF48D058)
                          : const Color(0xFF6B7280))),
            ),
          ),
        );
      }),
      const SizedBox(height: 4),
      _btn('↩ Fugir (indisponível contra chefe)',
          const Color(0xFF1F1F1F), const Color(0xFF9CA3AF), null,
          border: Border.all(color: const Color(0xFF374151))),
    ]);
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback? onTap,
      {BoxBorder? border}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 11, color: fg)),
      ),
    );
  }
}