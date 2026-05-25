import 'package:flutter/material.dart';
import '../models/player.dart';
import 'continue_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});
  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameCtrl = TextEditingController();
  String _genero = 'masculino';

  String get _texto => _genero == 'feminino'
      ? 'Você é uma estudante da PUC-Campinas que, após a frustração de ter seu TCC recusado, acaba sendo transportada para uma versão alternativa e sombria da faculdade. Ela deve percorrer os blocos para enfrentar os desafios que representam sua jornada acadêmica.'
      : 'Você é um estudante da PUC-Campinas que, após a frustração de ter seu TCC recusado, acaba sendo transportado para uma versão alternativa e sombria da faculdade. Ele deve percorrer os blocos para enfrentar os desafios que representam sua jornada acadêmica.';

  void _iniciar() {
    final nome = _nameCtrl.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Digite o nome do personagem antes de continuar.')));
      return;
    }
    final player = Player(nome: nome, genero: _genero);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => ContinueScreen(player: player)));
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('Criação do Personagem',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
      ),
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
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(height: 16),
              const Icon(Icons.person, size: 72, color: Color(0xFF38BDF8)),
              const SizedBox(height: 12),
              const Text('DEFINA SEU PERSONAGEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      letterSpacing: 2, color: Colors.white)),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFF111827).withOpacity(0.92),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    const Text('Nome do personagem',
                        style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite o nome',
                        hintStyle:
                            const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF1F2937),
                        prefixIcon: const Icon(Icons.badge,
                            color: Color(0xFF38BDF8)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFF64748B))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF38BDF8), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Sexo do personagem',
                        style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _generoBtn('Masculino', Icons.male, 'masculino'),
                      const SizedBox(width: 12),
                      _generoBtn('Feminino', Icons.female, 'feminino'),
                    ]),
                    const SizedBox(height: 16),
                    // Fotos dos personagens
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      _fotoPersonagem('assets/characters/mascu.png',
                          'masculino'),
                      const SizedBox(width: 20),
                      _fotoPersonagem('assets/characters/feminina.png',
                          'feminino'),
                    ]),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(_texto,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                              fontSize: 15, height: 1.5,
                              color: Color(0xFFE5E7EB))),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: _iniciar,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Começar Jornada',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 0.7)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _generoBtn(String label, IconData icon, String valor) {
    final sel = _genero == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _genero = valor),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sel ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
              width: 1.4,
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _fotoPersonagem(String path, String valor) {
    final sel = _genero == valor;
    return GestureDetector(
      onTap: () => setState(() => _genero = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90, height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? const Color(0xFF38BDF8) : const Color(0xFF374151),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(path,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => const Icon(Icons.person,
                  size: 48, color: Color(0xFF38BDF8))),
        ),
      ),
    );
  }
}
