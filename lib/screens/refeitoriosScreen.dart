import 'package:flutter/material.dart';

class RefeitorioScreen extends StatefulWidget {
  const RefeitorioScreen({super.key});
  @override
  State<RefeitorioScreen> createState() => _RefeitorioScreenState();
}

class _RefeitorioScreenState extends State<RefeitorioScreen> {
  int _hp = 80;
  final int _hpMax = 120;
  bool _curou = false;

  void _curar() => setState(() { _hp = _hpMax; _curou = true; });

  @override
  Widget build(BuildContext context) {
    final pct = _hp / _hpMax;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040), elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        title: const Text('REFEITÓRIO', style: TextStyle(fontFamily: 'monospace', fontSize: 12, letterSpacing: 3, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: Divider(height: 1, color: Color(0xFF2D1B69))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Zona segura
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF0A1808), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF48D058).withOpacity(0.5))),
            child: const Row(children: [
              Text('🛡', style: TextStyle(fontSize: 22)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ZONA SEGURA', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF48D058), letterSpacing: 2, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Nenhum inimigo pode atacar aqui.', style: TextStyle(fontFamily: 'monospace', fontSize: 8, color: Color(0xFF3A6030))),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // NPC Nutri
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF0C0820), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF48D058).withOpacity(0.3))),
            child: Column(children: [
              const Text('👨‍🍳', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              const Text('NUTRI', style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF48D058), letterSpacing: 2)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF141028), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3D2F6A))),
                child: Text(
                  _curou
                      ? '"Já está recuperado! Boa sorte nos desafios!"'
                      : '"Você chegou na hora certa. Um café energético e você estará pronto!"',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFFD0C8FF), height: 1.7),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // HP bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF0C0820), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2D1B69))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('SEU HP', style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF7C6FAF))),
                Text('$_hp / $_hpMax', style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFFD0C8FF), fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, minHeight: 14,
                  backgroundColor: const Color(0xFF0A0630),
                  valueColor: AlwaysStoppedAnimation(
                    pct > 0.5 ? const Color(0xFF48D058) : pct > 0.2 ? const Color(0xFFE8C840) : const Color(0xFFE84040),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Botão curar
          if (!_curou)
            GestureDetector(
              onTap: _curar,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(color: const Color(0xFF0A2010), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF48D058))),
                child: const Center(child: Text('☕ TOMAR CAFÉ ENERGÉTICO\n(RESTAURA HP CHEIO)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: Color(0xFF48D058), fontWeight: FontWeight.bold))),
              ),
            ),

          if (_curou) ...[
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF0A2010), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF48D058).withOpacity(0.5))),
              child: const Center(child: Text('✅ HP RESTAURADO!',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFF48D058), fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 48,
                decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(8)),
                child: const Center(child: Text('↩ VOLTAR AO MAPA',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
