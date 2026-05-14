import 'package:flutter/material.dart';
import 'screens/localizacaoScreen.dart';
import 'screens/AmbienteScreen.dart';
import 'screens/CriacaoPersonagemScreen.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎓', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 10),
                const Text('PUC CAMPINAS · RPG ACADÊMICO',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, letterSpacing: 4, color: Color(0xFF7C6FAF))),
                const SizedBox(height: 18),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'monospace', fontSize: 50, fontWeight: FontWeight.w900, height: 0.95, letterSpacing: 2),
                    children: [
                      TextSpan(text: 'JOURNEY\n', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'DEGREE', style: TextStyle(color: Color(0xFFA78BFA))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('"Explore o campus. Conquiste seu diploma."',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 2, color: Color(0xFF5C4F8A))),
                Container(margin: const EdgeInsets.symmetric(vertical: 24), width: 48, height: 2, color: const Color(0xFFA78BFA)),
                _MenuButton(
                  label: 'NOVO JOGO', icon: Icons.play_arrow_rounded, primary: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CriacaoPersonagemScreen())),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'CONTINUAR JORNADA', icon: Icons.map_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbienteScreen())),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'LOCALIZAÇÃO', icon: Icons.my_location_rounded,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizacaoScreen())),
                ),
                const SizedBox(height: 10),
                _MenuButton(label: 'CONFIGURAÇÕES', icon: Icons.settings_rounded, onTap: () {}),
                const SizedBox(height: 10),
                _MenuButton(label: 'LOGOUT', icon: Icons.logout_rounded, onTap: () => Navigator.pushReplacementNamed(context, '/')),
                const SizedBox(height: 28),
                const Text('v0.1.0 — SPRINT 1',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, letterSpacing: 3, color: Color(0xFF2E2458))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.icon, this.primary = false, required this.onTap});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            color: widget.primary ? const Color(0xFF7C3AED) : const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.primary ? const Color(0xFF7C3AED) : const Color(0xFFA78BFA).withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(children: [
            const SizedBox(width: 18),
            Icon(widget.icon, color: widget.primary ? Colors.white : const Color(0xFFC4B5FD), size: 18),
            const SizedBox(width: 12),
            Text(widget.label, style: TextStyle(
              fontFamily: 'monospace', fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold,
              color: widget.primary ? Colors.white : const Color(0xFFC4B5FD),
            )),
          ]),
        ),
      ),
    );
  }
}
