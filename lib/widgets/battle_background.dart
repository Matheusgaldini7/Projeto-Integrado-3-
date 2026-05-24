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

    final feminino = genero == 'feminino';

    switch (chefe) {

      case 'maligno':
        return feminino
            ? 'assets/battles/battleMalign_f.png'
            : 'assets/battles/battle_maligno_m.png';

      case 'derivador':
        return feminino
            ? 'assets/battles/battle_deri_f.png'
            : 'assets/battles/battle_deriv _m.png';

      case 'compilador':
        return feminino
            ? 'assets/battles/battle_prog_f.png'
            : 'assets/battles/battle_progr_m.png';

      case 'magnifico':
        return feminino
            ? 'assets/battles/battleMagnificoF.png'
            : 'assets/battles/battle_magni_ m.png';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      color: const Color(0xFF111827),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: const BorderSide(
          color: Color(0xFF64748B),
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),

        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,

          child: Image.asset(
            _path,

            width: double.infinity,

            fit: BoxFit.scaleDown,

            alignment: Alignment.center,

            errorBuilder: (_, __, ___) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}