import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _som = true;
  double _musica = 0.7;
  double _efeitos = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF111827).withOpacity(0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  const Icon(Icons.settings, size: 48,
                      color: Color(0xFF38BDF8)),
                  const SizedBox(height: 8),
                  const Text('AJUSTES DO SISTEMA',
                      style: TextStyle(color: Color(0xFF38BDF8),
                          fontSize: 15, fontWeight: FontWeight.bold,
                          letterSpacing: 1.4)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _som,
                    activeColor: const Color(0xFF38BDF8),
                    title: const Text('Som ativado',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    secondary: const Icon(Icons.volume_up,
                        color: Color(0xFF38BDF8)),
                    onChanged: (v) => setState(() => _som = v),
                  ),
                  const Divider(color: Color(0xFF334155)),
                  _slider('Música', Icons.music_note, _musica,
                      (v) => setState(() => _musica = v)),
                  const SizedBox(height: 8),
                  _slider('Efeitos sonoros', Icons.graphic_eq, _efeitos,
                      (v) => setState(() => _efeitos = v)),
                ]),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _slider(String title, IconData icon, double value,
      ValueChanged<double> onChange) {
    return Opacity(
      opacity: _som ? 1.0 : 0.4,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 10),
          Text('$title: ${(value * 100).round()}%',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        Slider(
          value: value, min: 0, max: 1, divisions: 10,
          activeColor: const Color(0xFF38BDF8),
          inactiveColor: const Color(0xFF334155),
          onChanged: _som ? onChange : null,
        ),
      ]),
    );
  }
}
