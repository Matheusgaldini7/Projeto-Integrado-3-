import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final String label;
  final int hp;
  final int hpMax;
  const HpBar({super.key, required this.label, required this.hp, required this.hpMax});

  Color get _cor {
    final p = hp / hpMax;
    if (p > 0.5) return const Color(0xFF48D058);
    if (p > 0.2) return const Color(0xFFE8C840);
    return const Color(0xFFE84040);
  }

  @override
  Widget build(BuildContext context) {
    final pct = (hp / hpMax).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFFD0C8FF))),
        Text('$hp/$hpMax', style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFFD0C8FF))),
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
          child: Container(color: _cor),
        ),
      ),
    ]);
  }
}
