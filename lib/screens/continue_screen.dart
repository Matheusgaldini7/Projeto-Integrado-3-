import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fase_data.dart';
import '../models/player.dart';
import '../services/location_service.dart';
import '../widgets/mini_mapa.dart';

const bool _ignorarGpsParaTeste = true;

class ContinueScreen extends StatefulWidget {
  final Player player;
  const ContinueScreen({super.key, required this.player});

  @override
  State<ContinueScreen> createState() => _ContinueScreenState();
}

class _ContinueScreenState extends State<ContinueScreen> {
  FaseData? _fase;
  double? _distancia;
  String _direcao = '';
  bool _dentroDoRaio = false;
  bool _loading = true;
  String _statusText = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fase = _findNextFase();
    _refreshLocation();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _refreshLocation());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  FaseData? _findNextFase() {
    for (final fase in fases) {
      if (fase.requisito == widget.player.fasesVencidas) {
        return fase;
      }
    }
    return null;
  }

  Future<void> _refreshLocation() async {
    if (_fase == null) return;
    setState(() {
      _loading = true;
      _statusText =
          _ignorarGpsParaTeste ? 'Modo teste: GPS liberado' : 'Buscando GPS...';
    });

    try {
      final distancia = await LocationService.distanciaAtualAte(
        _fase!.latitude,
        _fase!.longitude,
      );
      final direcao = await LocationService.direcao(
        _fase!.latitude,
        _fase!.longitude,
      );

      setState(() {
        _distancia = distancia;
        _direcao = direcao;
        _dentroDoRaio = distancia <= _fase!.raioMetros;
        _loading = false;
        _statusText = _ignorarGpsParaTeste
            ? 'Modo teste: entrada liberada'
            : _dentroDoRaio
                ? 'Local alcancado'
                : 'Va ate o local';
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _statusText = _ignorarGpsParaTeste
            ? 'Modo teste: entrada liberada sem GPS'
            : 'Erro de GPS: libere permissao';
        _distancia = null;
        _direcao = '';
        _dentroDoRaio = false;
      });
    }
  }

  String get _distanceLabel {
    if (_loading) return '...';
    if (_distancia == null) return '--';
    if (_distancia! >= 1000) {
      return '${(_distancia! / 1000).toStringAsFixed(1)} km';
    }
    return '${_distancia!.round()} m';
  }

  bool get _podeEntrar => _ignorarGpsParaTeste || _dentroDoRaio;

  void _entrarFase() {
    if (_fase == null || !_podeEntrar) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _fase!.tela(widget.player)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fase = _fase;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Continuar Jornada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: fase == null ? _buildFinished() : _buildFase(fase),
      ),
    );
  }

  Widget _buildFinished() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Voce ja completou todas as fases.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar ao menu'),
          ),
        ],
      ),
    );
  }

  Widget _buildFase(FaseData fase) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'OBJETIVO ATUAL',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Va ate ${fase.nome}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 220,
                    color: Colors.black,
                    child: Image.asset(
                      fase.imagem,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 220,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1F2937),
                        height: 220,
                        child: const Center(
                          child: Text(
                            'Imagem nao encontrada',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 220,
                  child: Card(
                    color: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: Color(0xFF64748B)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Mini Radar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: MiniMapa(
                              ambienteAlvo: fase.id,
                              compacto: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Distancia',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            _distanceLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Direcao: $_direcao',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFF64748B)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Raio de desbloqueio: ${fase.raioMetros.round()} m',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progresso: ${widget.player.fasesVencidas}/${fases.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _podeEntrar ? _entrarFase : null,
            icon: Icon(_podeEntrar ? Icons.sports_martial_arts : Icons.lock),
            label: Text(_podeEntrar ? 'Entrar na fase' : 'Fora da area'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _podeEntrar ? const Color(0xFF2563EB) : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _refreshLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar GPS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
