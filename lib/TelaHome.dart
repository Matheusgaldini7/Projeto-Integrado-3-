import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF1A1040),
    ),
  );
  runApp(const JourneyDegreeApp());
}

class JourneyDegreeApp extends StatelessWidget {
  const JourneyDegreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Degree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1040),
      ),
      home: const TelaHome(),
    );
  }
}

class TelaHome extends StatelessWidget {
  const TelaHome ({super.key});

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
                // Logo
                const Text('🎓', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 10),

                // Tag
                const Text(
                  'PUC CAMPINAS · RPG ACADÊMICO',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 4,
                    color: Color(0xFF7C6FAF),
                  ),
                ),
                const SizedBox(height: 18),

                // Título
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: 2,
                    ),
                    children: [
                      TextSpan(
                        text: 'JOURNEY\n',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'DEGREE',
                        style: TextStyle(color: Color(0xFFA78BFA)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Subtítulo
                const Text(
                  '"Explore o campus. Conquiste seu diploma."',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Color(0xFF5C4F8A),
                  ),
                ),

                // Divisor
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  width: 48,
                  height: 2,
                  color: const Color(0xFFA78BFA),
                ),

                // Botões
                _MenuButton(
                  label: 'NOVO JOGO',
                  icon: Icons.play_arrow_rounded,
                  primary: true,
                  onTap: () => _showDialog(
                    context,
                    'Novo Jogo',
                    'Iniciar uma nova aventura?\nToda a progressão será zerada.',
                  ),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'CONTINUAR',
                  icon: Icons.restore_rounded,
                  onTap: () => _showDialog(
                    context,
                    'Continuar',
                    'Carregando último save…\n[em breve]',
                  ),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'CONFIGURAÇÕES',
                  icon: Icons.settings_rounded,
                  onTap: () => _showDialog(
                    context,
                    'Configurações',
                    'Áudio, controles e acessibilidade.\n[em breve]',
                  ),
                ),
                const SizedBox(height: 10),
                _MenuButton(
                  label: 'CRÉDITOS',
                  icon: Icons.people_rounded,
                  onTap: () => _showDialog(
                    context,
                    'Créditos',
                    'Desenvolvido como projeto de extensão\nPUC-Campinas — Sprint 1 🎓',
                  ),
                ),

                const SizedBox(height: 28),

                // Versão
                const Text(
                  'v0.1.0 — SPRINT 1',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 3,
                    color: Color(0xFF2E2458),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
              color: Color(0xFFA78BFA), width: 1.5),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFC4B5FD),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: Color(0xFF7C6FAF),
            height: 1.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    this.primary = false,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: widget.primary
                ? const Color(0xFF7C3AED)
                : const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.primary
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFA78BFA).withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(
                widget.icon,
                color: widget.primary
                    ? Colors.white
                    : const Color(0xFFC4B5FD),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: widget.primary
                      ? Colors.white
                      : const Color(0xFFC4B5FD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}