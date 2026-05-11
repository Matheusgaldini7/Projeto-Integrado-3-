import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'character_creation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void startGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterCreationScreen(),
      ),
    );
  }

  void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void openCredits(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Créditos'),
          content: const Text(
            'Journey Degree\n\n'
            'PUC-Campinas\n'
            'Projeto Integrador III\n'
            'Sistemas de Informação\n\n'
            'Bruno Loureiro\n'
            'Lucas Alteri\n'
            'Matheus Caldas\n'
            'Matheus Galdini\n'
            'Yuri Kauan',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget menuButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: 260,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050816),
              Color(0xFF111827),
              Color(0xFF1E1B4B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              const Icon(
                Icons.school,
                size: 82,
                color: Color(0xFF38BDF8),
              ),

              const SizedBox(height: 20),

              const Text(
                'JOURNEY DEGREE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Não é possível sair até a conclusão do curso.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFCBD5E1),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 36),

              Container(
                width: 310,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'É um estudante da PUC-Campinas que, após a frustração de ter seu TCC recusado, acaba sendo transportado' 
                  'para uma versão alternativa e sombria da faculdade.'
                  'Ele deve percorrer os blocos para enfrentar os desafios que representam sua jornada acadêmica.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              menuButton(
                text: 'Iniciar Jogo',
                icon: Icons.play_arrow,
                onPressed: () => startGame(context),
              ),

              menuButton(
                text: 'Configurações',
                icon: Icons.settings,
                onPressed: () => openSettings(context),
              ),

              menuButton(
                text: 'Créditos',
                icon: Icons.info_outline,
                onPressed: () => openCredits(context),
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Campus I - PUC-Campinas',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}