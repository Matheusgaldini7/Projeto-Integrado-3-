import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'CriacaoPersonagemScreen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      if (mounted) {
        setState(() => _carregando = false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _carregando = false;

        if (e.code == 'invalid-credential') {
          _erro = 'Email ou senha incorretos';
        } else {
          _erro = 'Erro ao fazer login';
        }
      });
      
    } catch (e) {
        setState(() {
          _carregando = false;
          _erro = 'Erro inesperado';
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    style: TextStyle(fontFamily: 'monospace', fontSize: 42, fontWeight: FontWeight.w900, height: 0.95, letterSpacing: 2),
                    children: [
                      TextSpan(text: 'JOURNEY\n', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'DEGREE', style: TextStyle(color: Color(0xFFA78BFA))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                _Input(
                  controller: _emailController,
                  label: 'EMAIL',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 12),
                _Input(
                  controller: _senhaController,
                  label: 'SENHA DE ACESSO',
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                ),

                if (_erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('✕ $_erro',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFE84040))),
                  ),

                const SizedBox(height: 24),
                _Btn(
                  label: _carregando ? 'AUTENTICANDO...' : 'ENTRAR NO CAMPUS',
                  cor: const Color(0xFF7C3AED),
                  onTap: _carregando ? () {} : _entrar,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _Btn(
                        label: 'Google', // Deixe vazio pois a imagem já tem o texto
                        imagePath: 'assets/images/google_icon.png',
                        cor: const Color(0xFF120830),
                        borda: const Color(0xFF3D2F6A),
                        onTap: () => print('Login Google'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Btn(
                        label: '', // Deixe vazio
                        imagePath: 'assets/images/microsoft_icon.png',
                        cor: const Color(0xFF120830),
                        borda: const Color(0xFF3D2F6A),
                        onTap: () => print('Login Microsoft'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('v0.1.0 — SPRINT 1',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, letterSpacing: 3, color: Color(0xFF2E2458))),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: TextButton(
          onPressed: () {
            print('Ir para cadastro');
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFA78BFA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            enableFeedback: false,
          ),
          child: const Text(
            'CRIAR CONTA ➔',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  const _Input({required this.controller, required this.label, required this.icon, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0630),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D1B69), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFF5C4F8A))),
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFA78BFA)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final String label;
  final Color cor;
  final Color? borda;
  final VoidCallback onTap;
  final String? imagePath;
  const _Btn({
    required this.label,
    required this.cor,
    this.borda,
    required this.onTap,
    this.imagePath,
  });

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity, 
          height: 48,
          decoration: BoxDecoration(
            color: widget.cor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.borda ?? widget.cor, width: 2),
          ),
          child: Center(
            child: widget.imagePath != null
                ? Image.asset(
                    widget.imagePath!, 
                    height: 48, 
                    fit: BoxFit.contain,
                  )
                : Text(
                    widget.label, 
                    style: const TextStyle(
                      fontFamily: 'monospace', 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
