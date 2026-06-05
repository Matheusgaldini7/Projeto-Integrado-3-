import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _authService = AuthService();
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

  void _cadastrar() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _authService.cadastrar(
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📝', style: TextStyle(fontSize: 56)),
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
                  label: _carregando ? 'CRIANDO MATRÍCULA...' : 'Cadastrar',
                  cor: const Color(0xFF7C3AED),
                  borda: const Color(0xFF3D2F6A),
                  onTap: _carregando ? () {} : _cadastrar,
                ),
                const SizedBox(height: 32),
                const Text('v0.1.0 — SPRINT 1',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, letterSpacing: 3, color: Color(0xFF2E2458))),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: tecladoAberto
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF7C6FAF),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      enableFeedback: false,
                    ),
                    child: const Text(
                      '➔ VOLTAR PARA O LOGIN',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
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
                  keyboardType: label == 'EMAIL' ? TextInputType.emailAddress : TextInputType.text,
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
  const _Btn({required this.label, required this.cor, this.borda, required this.onTap});

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
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
            child: Text(
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