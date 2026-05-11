import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = true;

  double musicVolume = 0.7;

  double effectsVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),

      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
        elevation: 8,
      ),

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

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                color: const Color(0xFF111827).withOpacity(0.92),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(
                    color: Color(0xFF38BDF8),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.settings,
                        size: 58,
                        color: Color(0xFF38BDF8),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'AJUSTES DO SISTEMA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Configure o áudio e os efeitos do jogo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 24),

                      SwitchListTile(
                        value: soundEnabled,
                        activeColor: const Color(0xFF38BDF8),
                        title: const Text(
                          'Som ativado',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Ativa ou desativa todos os sons do jogo.',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        secondary: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF38BDF8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            soundEnabled = value;
                          });
                        },
                      ),

                      const Divider(color: Color(0xFF334155)),

                      settingSlider(
                        title: 'Música',
                        icon: Icons.music_note,
                        value: musicVolume,
                        enabled: soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            musicVolume = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      settingSlider(
                        title: 'Efeitos sonoros',
                        icon: Icons.graphic_eq,
                        value: effectsVolume,
                        enabled: soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            effectsVolume = value;
                          });
                        },
                      ),

                      const Divider(color: Color(0xFF334155)),

                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Voltar',
                    style: TextStyle(
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingSlider({
    required String title,
    required IconData icon,
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF38BDF8),
              ),
              const SizedBox(width: 10),
              Text(
                '$title: ${(value * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: const Color(0xFF38BDF8),
            inactiveColor: const Color(0xFF334155),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}