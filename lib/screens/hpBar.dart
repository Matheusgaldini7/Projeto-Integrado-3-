import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final String label;
  final int hp;
  final int hpMax;
  const HpBar({super.key, required this.label, required this.hp, required this.hpMax});

  Color get _cor {
    // vermelho se hp absoluto <= 30, amarelo se <= 50%, verde acima
    if (hp <= 30)              return const Color(0xFFE84040);
    if (hp / hpMax <= 0.5)    return const Color(0xFFE8C840);
    return const Color(0xFF48D058);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (hp / hpMax).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'monospace', fontSize: 9,
                color: Color(0xFFD0C8FF))),
        Text('$hp/$hpMax',
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                color: _cor,          // número muda de cor junto
                fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 4),
      Container(
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0630),
          border: Border.all(color: const Color(0xFF6050C0), width: 2),
        ),
        child: FractionallySizedBox(
          widthFactor: pct,
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _cor,
          ),
        ),
      ),
    ]);
  }
}