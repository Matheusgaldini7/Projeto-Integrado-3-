import 'package:flutter/material.dart';
import '../models/player.dart';
import 'character_creation_screen.dart';
import 'continue_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _creditos(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF111827),
      title: const Text('Créditos'),
      content: const Text(
        'Journey Degree\n\nPUC-Campinas\nProjeto Integrador III\nSistemas de Informação\n\n'
        'Bruno Loureiro\nLucas Alteri\nMatheus Caldas\nMatheus Galdini\nYuri Kauan',
      ),
      actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'))],
    ));
  }

  Widget _btn(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(width: 260, height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed, icon: Icon(icon),
          label: Text(text,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                  letterSpacing: 0.8)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = Player(nome: 'Aluno', genero: 'masculino');

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050816), Color(0xFF111827), Color(0xFF1E1B4B)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            const Spacer(),
            const Icon(Icons.school, size: 82, color: Color(0xFF38BDF8)),
            const SizedBox(height: 20),
            const Text('JOURNEY DEGREE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,
                    letterSpacing: 3, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Não é possível sair até a conclusão do curso.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFFCBD5E1),
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 36),
            _btn(context, 'Iniciar Jogo', Icons.play_arrow, () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const CharacterCreationScreen()))),
            _btn(context, 'Continuar', Icons.play_circle_outline, () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ContinueScreen(player: player)))),
            _btn(context, 'Configurações', Icons.settings, () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SettingsScreen()))),
            _btn(context, 'Créditos', Icons.info_outline,
                () => _creditos(context)),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Campus I - PUC-Campinas',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          ]),
        ),
      ),
    );
  }
}
