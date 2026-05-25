import 'package:flutter/material.dart';
import '../services/ConfiguracoesService.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final ConfiguracoesService _config = ConfiguracoesService();

  @override
  void initState() {
    super.initState();
    _config.addListener(_atualizarTela);
  }

  @override
  void dispose() {
    _config.removeListener(_atualizarTela);
    super.dispose();
  }

  void _atualizarTela() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        title: const Text(
          'CONFIGURACOES',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            letterSpacing: 3,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF2D1B69)),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Cabecalho(
              icon: Icons.settings_rounded,
              titulo: 'AJUSTES DO JOGO',
              subtitulo: 'Controle volume e brilho.',
            ),
            const SizedBox(height: 18),
            _Painel(
              children: [
                _SwitchOpcao(
                  icon: _config.somAtivo
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  titulo: 'SOM DO JOGO',
                  subtitulo: _config.somAtivo ? 'Ativado' : 'Mudo',
                  ativo: _config.somAtivo,
                  onChanged: _config.alternarSom,
                ),
                const _Separador(),
                _SliderOpcao(
                  icon: Icons.graphic_eq_rounded,
                  titulo: 'VOLUME',
                  valor: _config.volumeSalvo,
                  textoValor: '${(_config.volume * 100).round()}%',
                  onChanged: _config.somAtivo ? _config.atualizarVolume : null,
                ),
                const _Separador(),
                _SliderOpcao(
                  icon: Icons.wb_sunny_outlined,
                  titulo: 'LUMINOSIDADE',
                  valor: _config.luminosidade,
                  min: 0.25,
                  textoValor: '${(_config.luminosidade * 100).round()}%',
                  onChanged: _config.atualizarLuminosidade,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _BotaoRestaurar(onTap: _config.restaurarPadrao),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;

  const _Cabecalho({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFA78BFA), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFFC4B5FD), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFF7C6FAF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Painel extends StatelessWidget {
  final List<Widget> children;

  const _Painel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0630),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D1B69), width: 2),
      ),
      child: Column(children: children),
    );
  }
}

class _SliderOpcao extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final double valor;
  final double min;
  final String textoValor;
  final ValueChanged<double>? onChanged;

  const _SliderOpcao({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.textoValor,
    required this.onChanged,
    this.min = 0,
  });

  @override
  Widget build(BuildContext context) {
    final ativo = onChanged != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ativo
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF5C4F8A),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: ativo ? Colors.white : const Color(0xFF5C4F8A),
                  ),
                ),
              ),
              Text(
                textoValor,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: ativo
                      ? const Color(0xFFC4B5FD)
                      : const Color(0xFF5C4F8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFA78BFA),
              inactiveTrackColor: const Color(0xFF2D1B69),
              thumbColor: const Color(0xFFFFFFFF),
              overlayColor: const Color(0x337C3AED),
            ),
            child: Slider(
              min: min,
              max: 1,
              divisions: 10,
              value: valor.clamp(min, 1).toDouble(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchOpcao extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final bool ativo;
  final ValueChanged<bool> onChanged;

  const _SwitchOpcao({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.ativo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFA78BFA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    color: Color(0xFF7C6FAF),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: ativo,
            activeColor: const Color(0xFFA78BFA),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _BotaoRestaurar extends StatefulWidget {
  final VoidCallback onTap;

  const _BotaoRestaurar({required this.onTap});

  @override
  State<_BotaoRestaurar> createState() => _BotaoRestaurarState();
}

class _BotaoRestaurarState extends State<_BotaoRestaurar> {
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
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFA78BFA).withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restart_alt_rounded,
                color: Color(0xFFC4B5FD),
                size: 18,
              ),
              SizedBox(width: 10),
              Text(
                'RESTAURAR PADRAO',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Color(0xFFC4B5FD),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFF2D1B69));
  }
}
