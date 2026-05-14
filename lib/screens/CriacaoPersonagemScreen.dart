import 'package:flutter/material.dart';

class CriacaoPersonagemScreen extends StatefulWidget {
  const CriacaoPersonagemScreen({super.key});

  @override
  State<CriacaoPersonagemScreen> createState() => _CriacaoPersonagemScreenState();
}

class _CriacaoPersonagemScreenState extends State<CriacaoPersonagemScreen> {
  final _nomeController = TextEditingController();
  String _genero = ''; // 'M' ou 'F'
  int _etapa = 0; // 0: Gênero, 1: Nome/Stats

  void _proximo() {
    if (_etapa == 0 && _genero.isEmpty) return;
    if (_etapa == 1 && _nomeController.text.isEmpty) return;
    
    if (_etapa == 0) {
      setState(() => _etapa = 1);
    } else {
      _finalizar();
    }
  }

  void _finalizar() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFA78BFA))),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pop(context); // fecha loading
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFA78BFA), size: 18),
          onPressed: () => _etapa == 0 ? Navigator.pop(context) : setState(() => _etapa = 0),
        ),
        title: const Text('NOVO PERSONAGEM',
            style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: Color(0xFF2D1B69))),
      ),
      body: Column(
        children: [
          // ── Progresso ──
          Container(
            color: const Color(0xFF100830),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Row(
              children: [
                _Step(label: 'GÊNERO', active: _etapa == 0, done: _etapa > 0),
                Expanded(child: Container(height: 2, color: const Color(0xFF2D1B69), margin: const EdgeInsets.symmetric(horizontal: 12))),
                _Step(label: 'ATRIBUTOS', active: _etapa == 1, done: false),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _etapa == 0 ? _buildGenero() : _buildAtributos(),
            ),
          ),

          // ── Ação ──
          Padding(
            padding: const EdgeInsets.all(24),
            child: _Btn(
              label: _etapa == 0 ? 'CONTINUAR' : 'INICIAR JORNADA',
              cor: (_etapa == 0 && _genero.isEmpty) ? const Color(0xFF2D1B69) : const Color(0xFF7C3AED),
              onTap: _proximo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECIONE SEU AVATAR',
            style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 1, color: Color(0xFF7C6FAF))),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _AvatarCard(
              label: 'MASCULINO', emoji: '🧑‍🎓', selected: _genero == 'M',
              onTap: () => setState(() => _genero = 'M'),
            )),
            const SizedBox(width: 16),
            Expanded(child: _AvatarCard(
              label: 'FEMININO', emoji: '👩‍🎓', selected: _genero == 'F',
              onTap: () => setState(() => _genero = 'F'),
            )),
          ],
        ),
        const SizedBox(height: 32),
        const Text('▸ O gênero não afeta os atributos iniciais, apenas a aparência do seu personagem no campus.',
            style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF5C4F8A), height: 1.5)),
      ],
    );
  }

  Widget _buildAtributos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DADOS DO ESTUDANTE',
            style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 1, color: Color(0xFF7C6FAF))),
        const SizedBox(height: 16),
        _Input(controller: _nomeController, label: 'NOME DO PERSONAGEM', icon: Icons.badge_outlined),
        const SizedBox(height: 32),
        const Text('ATRIBUTOS INICIAIS',
            style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 1, color: Color(0xFF7C6FAF))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0630),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3D2F6A), width: 2),
          ),
          child: const Column(
            children: [
              _StatRow(label: '❤️ VITALIDADE (HP)', value: '100'),
              _StatRow(label: '⚔️ FORÇA ACADÊMICA', value: '10'),
              _StatRow(label: '🛡️ RESILIÊNCIA', value: '08'),
              _StatRow(label: '⚡ AGILIDADE', value: '07'),
              _StatRow(label: '🧠 INTELIGÊNCIA', value: '09'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool active;
  final bool done;
  const _Step({required this.label, required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF48D058) : active ? const Color(0xFF7C3AED) : Colors.transparent,
            border: Border.all(color: done ? const Color(0xFF48D058) : active ? const Color(0xFFA78BFA) : const Color(0xFF2D1B69), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
          fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold,
          color: active || done ? Colors.white : const Color(0xFF5C4F8A),
        )),
      ],
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _AvatarCard({required this.label, required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E1250) : const Color(0xFF0C0630),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFFA78BFA) : const Color(0xFF2D1B69), width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(
              fontFamily: 'monospace', fontSize: 9, fontWeight: FontWeight.bold,
              color: selected ? Colors.white : const Color(0xFF5C4F8A),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF7C6FAF))),
          Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA78BFA))),
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  const _Input({required this.controller, required this.label, required this.icon});

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
  final VoidCallback onTap;
  const _Btn({required this.label, required this.cor, required this.onTap});

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
          width: double.infinity, height: 48,
          decoration: BoxDecoration(
            color: widget.cor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(widget.label, style: const TextStyle(
              fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white,
            )),
          ),
        ),
      ),
    );
  }
}
