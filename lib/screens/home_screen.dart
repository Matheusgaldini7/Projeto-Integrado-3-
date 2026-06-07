import 'package:flutter/material.dart';
import 'character_creation_screen.dart';
import 'continue_screen.dart';
import 'settings_screen.dart';
import '../services/jogador_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JogadorService _jogadorService = JogadorService();

  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _iniciarJogo() async {
    final jogador = await _jogadorService.carregarJogador();

    if (!mounted) return;
    if (jogador != null && jogador.nickname.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContinueScreen(
            player: jogador,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CharacterCreationScreen(),
        ),
      );
    }
  }

  Future<void> _novoJogo() async {
    final jogador = await _jogadorService.carregarJogador();

    if (!mounted) return;

    if (jogador != null && jogador.nickname.trim().isNotEmpty) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Novo Jogo'),
          content: const Text(
            'Criar um novo personagem irá sobrescrever o progresso atual.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCreationScreen(),
      ),
    );
  }

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
            _btn(
              context,
              'Novo Jogo',
              Icons.play_arrow,
              _novoJogo,
            ),
            _btn(
              context,
              'Continuar',
              Icons.explore,
              _iniciarJogo,
            ),
            _btn(context, 'Configurações', Icons.settings, () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const SettingsScreen()))),
            _btn(context, 'Créditos', Icons.info_outline,
                () => _creditos(context)),
            const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.logout,
                          size: 22,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const Text(
                      'Campus I - PUC-Campinas',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
