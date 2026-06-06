import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/player.dart';
import '../services/audio_manager.dart';
import '../services/location_service.dart';
import '../widgets/mini_mapa.dart';
import 'h15_screen.dart';
import 'politecnica_screen.dart';
import 'h06_screen.dart';
import 'auditorio_screen.dart';
import 'refeitorio_screen.dart';

class ContinueScreen extends StatefulWidget {
  final Player player;
  // Quando preenchido, ignora fasesVencidas e força o destino informado.
  final String? destinoOverride;
  const ContinueScreen({super.key, required this.player, this.destinoOverride});

  @override
  State<ContinueScreen> createState() => _ContinueScreenState();
}

class _ContinueScreenState extends State<ContinueScreen> {
  Position? _pos;
  bool _carregando = true;
  String? _erro;
  StreamSubscription<Position>? _locSub;

  _ObjetivoAtual get _objetivo {
    // Destino forçado (ex.: waypoint do Refeitório após H15 ou Politécnica)
    if (widget.destinoOverride == 'refeitorio') {
      return _ObjetivoAtual(
        nome: 'Refeitório',
        chamada: 'Vá até o Refeitório para descansar e se preparar.',
        id: 'refeitorio',
        imagem: 'assets/backgrounds/refeitorio.png',
        destino: RefeitorioScreen(
          player: widget.player,
          voltouDeH15: widget.player.fasesVencidas == 1,
        ),
      );
    }

    final fases = widget.player.fasesVencidas;
    if (fases <= 0) {
      return _ObjetivoAtual(
        nome: 'Bloco H15',
        chamada: 'Vá até o H15 para iniciar a primeira avaliação.',
        id: 'h15',
        imagem: 'assets/backgrounds/h15_img.png',
        destino: H15Screen(player: widget.player),
      );
    }
    if (fases == 1) {
      return _ObjetivoAtual(
        nome: 'Politécnica',
        chamada: 'Vá até a Politécnica para enfrentar O Derivador.',
        id: 'politecnica',
        imagem: 'assets/backgrounds/ct.png',
        destino: PolitecnicaScreen(player: widget.player),
      );
    }
    if (fases == 2) {
      return _ObjetivoAtual(
        nome: 'Bloco H06',
        chamada: 'Vá até o H06 para enfrentar O Compilador.',
        id: 'h06',
        imagem: 'assets/backgrounds/h06.png',
        destino: H06Screen(player: widget.player),
      );
    }
    if (fases == 3) {
      return _ObjetivoAtual(
        nome: 'Auditório',
        chamada: 'Vá até o Auditório para enfrentar a aprovação final.',
        id: 'auditorio',
        imagem: 'assets/backgrounds/auditorio.png',
        destino: AuditorioScreen(player: widget.player),
      );
    }
    return _ObjetivoAtual(
      nome: 'Jornada concluída',
      chamada: 'Você já concluiu a jornada acadêmica.',
      id: 'auditorio',
      imagem: 'assets/backgrounds/auditorio.png',
      destino: AuditorioScreen(player: widget.player),
      finalizado: true,
    );
  }

  @override
  void initState() {
    super.initState();
    _iniciarStream();
    AudioManager.playExplorationMusic();
  }

  @override
  void dispose() {
    _locSub?.cancel();
    super.dispose();
  }

  Future<void> _iniciarStream() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      final pos = await LocationService.obterPosicao();
      if (!mounted) return;
      setState(() { _pos = pos; _carregando = false; });
      _locSub?.cancel();
      _locSub = LocationService.posicaoStream().listen(
        (p) { if (mounted) setState(() => _pos = p); },
        onError: (e) {
          if (!mounted) return;
          setState(() => _erro = e.toString().replaceAll('Exception: ', ''));
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceAll('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Ambiente get _ambiente => ambientesPUC.firstWhere((a) => a.id == _objetivo.id);

  double? get _distancia {
    if (_pos == null) return null;
    final a = _ambiente;
    return LocationService.distancia(
      _pos!.latitude,
      _pos!.longitude,
      a.latitude,
      a.longitude,
    );
  }

  bool get _dentroDoRaio {
    final d = _distancia;
    return d != null && d <= _ambiente.raioMetros;
  }

  String _distanciaTexto(double? dist) {
    if (dist == null) return '--';
    if (dist < 1000) return '${dist.toInt()}m';
    return '${(dist / 1000).toStringAsFixed(1)}km';
  }

  void _entrar() {
    if (!_dentroDoRaio || _objetivo.finalizado) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _objetivo.destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    final objetivo = _objetivo;
    final dist = _distancia;

    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('Continuar Jornada', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050816), Color(0xFF111827), Color(0xFF1E1B4B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _statusPlayer(),
                const SizedBox(height: 14),
                Card(
                  color: const Color(0xFF111827).withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'OBJETIVO ATUAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          objetivo.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          objetivo.chamada,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFCBD5E1), height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 180,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: const Color(0xFF020617),
                                    child: Image.asset(
                                      objetivo.imagem,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: Color(0xFF64748B),
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: MiniMapa(ambienteAlvo: objetivo.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _gpsStatus(dist),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _dentroDoRaio && !objetivo.finalizado ? _entrar : null,
                            icon: Icon(_dentroDoRaio ? Icons.sports_martial_arts : Icons.lock),
                            label: Text(
                              objetivo.finalizado
                                  ? 'Jornada concluída'
                                  : _dentroDoRaio
                                      ? 'Entrar em ${objetivo.nome}'
                                      : 'Fora da área — ${_distanciaTexto(dist)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF334155),
                              disabledForegroundColor: const Color(0xFF94A3B8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _iniciarStream,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar GPS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPlayer() => Card(
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                widget.player.nome.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Fases vencidas: ${widget.player.fasesVencidas}  ·  HP: ${widget.player.hp}/${widget.player.hpMax}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 13),
              ),
            ],
          ),
        ),
      );

  Widget _gpsStatus(double? dist) {
    if (_carregando) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Buscando GPS...', style: TextStyle(color: Color(0xFFCBD5E1))),
        ],
      );
    }
    if (_erro != null) {
      return Text(
        'GPS indisponível: $_erro',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
      );
    }
    if (_dentroDoRaio) {
      return const Text(
        '✅ Local alcançado. Entrada liberada.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF48D058), fontWeight: FontWeight.bold),
      );
    }
    return Text(
      '📍 Vá até o local. Distância: ${_distanciaTexto(dist)}',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
    );
  }
}

class _ObjetivoAtual {
  final String nome;
  final String chamada;
  final String id;
  final String imagem;
  final Widget destino;
  final bool finalizado;

  const _ObjetivoAtual({
    required this.nome,
    required this.chamada,
    required this.id,
    required this.imagem,
    required this.destino,
    this.finalizado = false,
  });
}
