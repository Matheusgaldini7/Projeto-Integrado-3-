import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/AmbientesMock.dart';
import '../models/Ambiente.dart';
import '../services/LocalizacaoService.dart';
import '../services/ProgressoService.dart';
import 'BatalhaScreen.dart';
import 'refeitoriosScreen.dart';

class AmbienteScreen extends StatefulWidget {
  const AmbienteScreen({super.key});
  @override
  State<AmbienteScreen> createState() => _AmbienteScreenState();
}

class _AmbienteScreenState extends State<AmbienteScreen> {
  final ProgressoService _prog = ProgressoService();
  final LocalizacaoService _geo = LocalizacaoService();
  Position? _pos;
  bool _gpsLoading = false;
  String? _gpsErro;
  int _sel = 0;

  @override
  void initState() {
    super.initState();
    _atualizarGps(); // ainda tenta pegar GPS, mas não bloqueia nada
  }

  Future<void> _atualizarGps() async {
    setState(() { _gpsLoading = true; _gpsErro = null; });
    try {
      final p = await _geo.obterPosicaoAtual();
      setState(() { _pos = p; _gpsLoading = false; });
    } catch (e) {
      setState(() {
        _gpsErro = e.toString().replaceAll('Exception: ', '');
        _gpsLoading = false;
      });
    }
  }

  Future<void> _entrar(Ambiente a) async {
    // Refeitório: sempre entra, GPS só mostra info
    if (a.id == 'refeitorio') {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RefeitorioScreen()));
      return;
    }

    // Sequência obrigatória mantida (derrote o chefe anterior)
    if (!_prog.sequenciaLiberada(a.id)) {
      final idx = ProgressoService.ordemChefes.indexOf(a.id);
      final ant = ambientesMock.firstWhere(
          (x) => x.id == ProgressoService.ordemChefes[idx - 1]);
      _snack('🔒 Derrote primeiro: ${ant.nome}');
      return;
    }

    // Sem verificação de raio — entra direto na batalha
    final venceu = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BatalhaScreen(ambienteId: a.id)),
    );
    if (venceu == true) {
      setState(() => _prog.registrarVitoria(a.id));
      _snack('★ ${a.nome} concluído! Próximo destino liberado.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
      backgroundColor: const Color(0xFF1E1250),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFA78BFA))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lista = _prog.ambientes;
    final proximo = _prog.proximoDestino;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1040),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFA78BFA)),
        title: const Text('AMBIENTES',
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                letterSpacing: 3,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _gpsLoading
                  ? Icons.gps_not_fixed
                  : Icons.gps_fixed_rounded,
              color: _pos != null
                  ? const Color(0xFF48D058)
                  : const Color(0xFF5C4F8A),
            ),
            onPressed: _atualizarGps,
            tooltip: 'Atualizar GPS (opcional)',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF2D1B69)),
        ),
      ),
      body: Column(children: [

        // ── GPS status (informativo, não bloqueia) ──
        GestureDetector(
          onTap: _atualizarGps,
          child: Container(
            color: const Color(0xFF0C0820),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Icon(
                _gpsLoading
                    ? Icons.gps_not_fixed
                    : _pos != null
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_off_rounded,
                size: 13,
                color: _gpsLoading
                    ? const Color(0xFFE8C840)
                    : _pos != null
                        ? const Color(0xFF48D058)
                        : const Color(0xFF5C4F8A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _gpsLoading
                      ? 'Obtendo GPS...'
                      : _pos != null
                          ? 'GPS: ${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}'
                          : 'GPS desativado (opcional) — toque para tentar',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    color: _gpsLoading
                        ? const Color(0xFFE8C840)
                        : _pos != null
                            ? const Color(0xFF48D058)
                            : const Color(0xFF5C4F8A),
                  ),
                ),
              ),
              const Text('↻',
                  style: TextStyle(
                      fontSize: 14, color: Color(0xFF5C4F8A))),
            ]),
          ),
        ),

        // ── Mini mapa com seta (só aparece se tiver GPS) ──
        if (proximo != null && _pos != null)
          _MiniMapa(pos: _pos!, destino: proximo, prog: _prog),

        // ── Barra de progresso ──
        Container(
          color: const Color(0xFF100830),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            const Text('PROGRESSO  ',
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    color: Color(0xFF5C4F8A))),
            ...ProgressoService.ordemChefes.map((id) {
              final v = _prog.foiVencido(id);
              final l = _prog.sequenciaLiberada(id);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  v ? '★' : l ? '○' : '✕',
                  style: TextStyle(
                      fontSize: 14,
                      color: v
                          ? const Color(0xFFE8C840)
                          : l
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF2D1B69)),
                ),
              );
            }),
          ]),
        ),

        // ── Lista de ambientes ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final a = lista[i];
              final isRef = a.id == 'refeitorio';
              final seqOk = isRef || _prog.sequenciaLiberada(a.id);
              final vencido = _prog.foiVencido(a.id);
              final sel = _sel == i;

              // Info de distância (só informativa, não bloqueia)
              int? dist;
              bool noLocal = false;
              if (_pos != null) {
                noLocal = _prog.dentroDoRaio(
                    ambienteId: a.id,
                    latAtual: _pos!.latitude,
                    lngAtual: _pos!.longitude);
                dist = _prog
                    .distanciaAte(
                        ambienteId: a.id,
                        latAtual: _pos!.latitude,
                        lngAtual: _pos!.longitude)
                    .toInt();
              }

              final bordaColor = vencido
                  ? const Color(0xFFE8C840)
                  : isRef
                      ? const Color(0xFF48D058)
                      : seqOk
                          ? const Color(0xFFA78BFA)
                          : const Color(0xFF2D1B69);

              return GestureDetector(
                onTap: () => setState(() => _sel = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF1E1250)
                        : const Color(0xFF120830),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: bordaColor, width: sel ? 2 : 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                      // Nome + badge
                      Row(children: [
                        Expanded(
                          child: Text(a.nome,
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: seqOk
                                      ? Colors.white
                                      : const Color(0xFF3D2F6A))),
                        ),
                        _Badge(
                          label: isRef
                              ? '🍽 CURA'
                              : vencido
                                  ? '★ VENCIDO'
                                  : seqOk
                                      ? '▶ LIVRE'
                                      : '✕ BLOQ.',
                          color: isRef
                              ? const Color(0xFF48D058)
                              : vencido
                                  ? const Color(0xFFE8C840)
                                  : seqOk
                                      ? const Color(0xFFA78BFA)
                                      : const Color(0xFF2D1B69),
                        ),
                      ]),

                      // Distância (informativa, se GPS disponível)
                      if (_pos != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(children: [
                            Icon(
                              noLocal
                                  ? Icons.location_on
                                  : Icons.location_searching,
                              size: 11,
                              color: noLocal
                                  ? const Color(0xFF48D058)
                                  : const Color(0xFF5C4F8A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              noLocal
                                  ? 'Você está aqui!'
                                  : '${dist}m de distância',
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: noLocal
                                      ? const Color(0xFF48D058)
                                      : const Color(0xFF5C4F8A)),
                            ),
                          ]),
                        ),

                      const SizedBox(height: 6),
                      Text(a.descricao,
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: seqOk
                                  ? const Color(0xFF7C6FAF)
                                  : const Color(0xFF2D1B69),
                              height: 1.6)),
                      const SizedBox(height: 8),

                      Wrap(spacing: 6, children: [
                        if (!isRef)
                          _Chip('⚔ ${a.chefe.toUpperCase()}', seqOk),
                        _Chip('🎁 ${a.itemRecompensa}', seqOk),
                        _Chip('📍 ${a.raioMetros.toInt()}m', seqOk),
                      ]),

                      // Botão entrar
                      if (sel) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _entrar(a),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isRef
                                  ? const Color(0xFF0A2010)
                                  : !seqOk
                                      ? const Color(0xFF1A0820)
                                      : vencido
                                          ? const Color(0xFF2A1800)
                                          : const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isRef
                                    ? const Color(0xFF48D058)
                                    : !seqOk
                                        ? const Color(0xFF2D1B69)
                                        : const Color(0xFFA78BFA),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isRef
                                    ? '🍽 ENTRAR (CURAR HP)'
                                    : !seqOk
                                        ? '🔒 COMPLETE A FASE ANTERIOR'
                                        : vencido
                                            ? '↩ REVISITAR'
                                            : '⚔ INICIAR DESAFIO',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: !seqOk
                                      ? const Color(0xFF3D2F6A)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ── Mini Mapa com seta (só aparece se GPS disponível) ──
class _MiniMapa extends StatelessWidget {
  final Position pos;
  final Ambiente destino;
  final ProgressoService prog;
  const _MiniMapa(
      {required this.pos, required this.destino, required this.prog});

  @override
  Widget build(BuildContext context) {
    final direcao = prog.direcaoParaDestino(
      latAtual: pos.latitude,
      lngAtual: pos.longitude,
      latAlvo: destino.latitude,
      lngAlvo: destino.longitude,
    );
    final dist = prog
        .distanciaAte(
            ambienteId: destino.id,
            latAtual: pos.latitude,
            lngAtual: pos.longitude)
        .toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0820),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFA78BFA).withOpacity(0.35)),
      ),
      child: Row(children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Transform.rotate(
            angle: direcao * math.pi / 180,
            child: CustomPaint(painter: _SetaPainter()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text('PRÓXIMO DESTINO',
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 7,
                    color: Color(0xFF5C4F8A),
                    letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(destino.nome,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              dist < 1000
                  ? '$dist metros'
                  : '${(dist / 1000).toStringAsFixed(1)} km',
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFFA78BFA)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SetaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2,
        cy = size.height / 2,
        r = size.width / 2 - 3;
    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = const Color(0xFF1A0E4F));
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFF6050C0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final p = Path()
      ..moveTo(cx, cy - r * 0.6)
      ..lineTo(cx - r * 0.28, cy + r * 0.3)
      ..lineTo(cx, cy + r * 0.1)
      ..lineTo(cx + r * 0.28, cy + r * 0.3)
      ..close();
    canvas.drawPath(p, Paint()..color = const Color(0xFFA78BFA));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.6))),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: color)),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool ativo;
  const _Chip(this.label, this.ativo);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: ativo
                ? const Color(0xFF1E1250)
                : const Color(0xFF0E0820),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 8,
                color: ativo
                    ? const Color(0xFFC4B5FD)
                    : const Color(0xFF2D1B69))),
      );
}