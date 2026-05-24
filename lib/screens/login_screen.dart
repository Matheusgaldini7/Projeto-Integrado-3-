import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cadastro_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _auth = AuthService();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      await _auth.login(email: _emailCtrl.text.trim(), senha: _senhaCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() { _erro = e.toString(); });
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(children: [
              const SizedBox(height: 20),
              const Icon(Icons.school, size: 72, color: Color(0xFF38BDF8)),
              const SizedBox(height: 16),
              const Text('JOURNEY DEGREE',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                      letterSpacing: 3, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Não é possível sair até a conclusão do curso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1),
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 36),
              Card(
                color: const Color(0xFF111827).withOpacity(0.92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    TextField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDeco('E-mail', Icons.email_outlined),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _senhaCtrl,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: _inputDeco('Senha', Icons.lock_outline),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 10),
                      Text(_erro!,
                          style: const TextStyle(
                              color: Color(0xFFEF4444), fontSize: 12)),
                    ],
                    const SizedBox(height: 18),
                    _carregando
                        ? const CircularProgressIndicator(
                            color: Color(0xFF38BDF8))
                        : Column(children: [
                            _rpgBtn('Entrar', Icons.login, _login),
                            const SizedBox(height: 10),
                        
                          ]),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CadastroScreen())),
                child: const Text('Não tem conta? Cadastre-se',
                    style: TextStyle(color: Color(0xFF38BDF8))),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        prefixIcon: Icon(icon, color: const Color(0xFF38BDF8)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF64748B))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
      );

  Widget _rpgBtn(String text, IconData icon, VoidCallback onPressed,
      {Color cor = const Color(0xFF2563EB)}) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed, icon: Icon(icon),
        label: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: cor, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
