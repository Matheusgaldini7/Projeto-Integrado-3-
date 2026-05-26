import 'package:flutter/material.dart';

class BattleBackground extends StatelessWidget {
  final String chefe;
  final String genero;

  const BattleBackground({
    super.key,
    required this.chefe,
    required this.genero,
  });

  String get _path {
    final f = genero == 'feminino';
    switch (chefe) {
      case 'maligno':
        return f ? 'assets/battles/battleMalign_f.png'
                 : 'assets/battles/battle_maligno_m.png';
      case 'derivador':
        return f ? 'assets/battles/battle_deri_f.png'
                 : 'assets/battles/battle_deriv _m.png';
      case 'compilador':
        return f ? 'assets/battles/battle_prog_f.png'
                 : 'assets/battles/battle_progr_m.png';
      case 'magnifico':
        return f ? 'assets/battles/battleMagnificoF.png'
                 : 'assets/battles/battle_magni_ m.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020617),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF38BDF8).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(
            _path,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0B0F14),
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    color: Color(0xFF374151), size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
