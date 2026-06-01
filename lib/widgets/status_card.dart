import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/battle_helper.dart';

class StatusCard extends StatelessWidget {
  final Player player;
  final String bossLabel;
  final int bossHp;
  final int bossHpMax;
  final bool showBoss;
  final BattleHelper battle;

  const StatusCard({
    super.key,
    required this.player,
    required this.bossLabel,
    required this.bossHp,
    required this.bossHpMax,
    required this.showBoss,
    required this.battle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          const Text('STATUS',
              style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12)),
          const Divider(color: Color(0xFF38BDF8)),
          _hpBar('❤️ ${player.nome}', player.hp, player.hpMax, Colors.redAccent),
          if (showBoss) ...[
            const SizedBox(height: 8),
            _hpBar('👾 $bossLabel', bossHp, bossHpMax, Colors.purpleAccent),
          ],
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 4, children: [
            Text('💰 ${player.dinheiro}cr',
                style: const TextStyle(fontSize: 11)),
            Text('⚔️ +${player.bonusAtaque}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF38BDF8))),
            if (player.skills.isNotEmpty)
              Text('✨ ${player.skills.join(", ")}',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFFA78BFA))),
          ]),
          if (showBoss && player.inventario.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Divider(color: Color(0xFF374151), height: 1),
            const SizedBox(height: 6),
            ...player.inventario
                .where((i) => catalogoItens.containsKey(i))
                .toSet()
                .map((nome) {
              final item = catalogoItens[nome]!;
              final ok = battle.itemDisponivel(nome);
              final faltam = battle.turnosParaItem(nome);
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(children: [
                  Text('${item.emoji} ',
                      style: const TextStyle(fontSize: 13)),
                  Text(item.nome,
                      style: TextStyle(
                          fontSize: 10,
                          color: ok
                              ? Colors.white
                              : const Color(0xFF6B7280))),
                  const Spacer(),
                  ok
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: const Color(0xFF48D058)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFF48D058))),
                          child: const Text('PRONTO',
                              style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF48D058),
                                  fontWeight: FontWeight.bold)),
                        )
                      : Text('$faltam turnos',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF6B7280))),
                ]),
              );
            }),
          ],
        ]),
      ),
    );
  }

  Widget _hpBar(String label, int hp, int max, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: $hp/$max',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: (hp / max).clamp(0.0, 1.0),
          minHeight: 10,
          backgroundColor: const Color(0xFF374151),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}