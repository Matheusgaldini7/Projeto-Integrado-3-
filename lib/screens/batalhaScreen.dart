import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/AmbientesMock.dart';
import '../data/ChefesMock.dart';
import '../models/Chefe.dart';
import '../widgets/HpBar.dart';

enum _Fase { intro, batalha, vitoria, derrota }

class BatalhaScreen extends StatefulWidget {
  final String ambienteId;
  const BatalhaScreen({super.key, required this.ambienteId});

  @override
  State<BatalhaScreen> createState() => _BatalhaScreenState();
}

class _BatalhaScreenState extends State<BatalhaScreen>
    with SingleTickerProviderStateMixin {
  late Chefe _chefe;
  late String _nomeAmbiente;

  // ── HP ──
  int _hpJ = 100;
  final int _hpMaxJ = 100;
  late int _hpC;

  // ── Contadores para critical / miss ──
  int _ataquesJogador = 0;   // a cada 5 o próximo é crítico
  int _ataquesChefe   = 0;
  int _missJogador    = 0;   // controla até 2 erros a cada 6 ataques
  int _missChefe      = 0;
  int _cicloMissJ     = 0;   // quantos ataques no ciclo de 6 atual
  int _cicloMissC     = 0;

  // ── Estado geral ──
  _Fase _fase = _Fase.intro;
  bool _animando = false;
  bool _shake = false;

  // ── Último evento (para exibir badge na arena) ──
  String _ultimoEvento = '';

  final List<String> _log = [];
  final ScrollController _scroll = ScrollController();
  final math.Random _rng = math.Random();

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final amb = ambientesMock.firstWhere((a) => a.id == widget.ambienteId);
    _nomeAmbiente = amb.nome;
    _chefe = chefesMock[amb.chefe]!;
    _hpC = _chefe.hpMax;

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeCtrl);

    Future.delayed(const Duration(milliseconds: 500),
        () { if (mounted) _addLog(_chefe.falaInicio); });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  void _addLog(String msg) {
    setState(() => _log.add(msg));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut);
      }
    });
  }

  Future<void> _doShake() async {
    setState(() => _shake = true);
    await _shakeCtrl.forward(from: 0);
    setState(() => _shake = false);
  }

  // ─── Lógica de acerto/erro/crítico do JOGADOR ───
  /// Retorna o dano causado (0 = errou, >0 = acertou / crítico)
  _AtaqueResult _calcularAtaqueJogador() {
    _ataquesJogador++;
    _cicloMissJ++;

    // ── MISS: sorteia aleatoriamente até 2 vezes dentro de cada ciclo de 6 ──
    if (_cicloMissJ <= 6) {
      // quantos erros ainda cabem neste ciclo?
      final errosCabem = 2 - _missJogador;
      final ataquesRestantes = 6 - (_cicloMissJ - 1);
      // probabilidade proporcional para distribuir os erros no ciclo
      if (errosCabem > 0 && _rng.nextInt(ataquesRestantes) < errosCabem) {
        _missJogador++;
        if (_cicloMissJ == 6) { _cicloMissJ = 0; _missJogador = 0; }
        return _AtaqueResult(dano: 0, tipo: _TipoAtaque.miss);
      }
    }
    if (_cicloMissJ >= 6) { _cicloMissJ = 0; _missJogador = 0; }

    // ── CRÍTICO: a cada 5 ataques bem-sucedidos ──
    final bool critico = _ataquesJogador % 5 == 0;
    final int base = 15 + _rng.nextInt(6); // 15-20
    final int dano = critico ? (base * 1.5).round() : base;
    return _AtaqueResult(
        dano: dano,
        tipo: critico ? _TipoAtaque.critico : _TipoAtaque.normal);
  }

  // ─── Lógica de acerto/erro/crítico do CHEFE ───
  _AtaqueResult _calcularAtaqueChefe() {
    _ataquesChefe++;
    _cicloMissC++;

    if (_cicloMissC <= 6) {
      final errosCabem = 2 - _missChefe;
      final ataquesRestantes = 6 - (_cicloMissC - 1);
      if (errosCabem > 0 && _rng.nextInt(ataquesRestantes) < errosCabem) {
        _missChefe++;
        if (_cicloMissC == 6) { _cicloMissC = 0; _missChefe = 0; }
        return _AtaqueResult(dano: 0, tipo: _TipoAtaque.miss);
      }
    }
    if (_cicloMissC >= 6) { _cicloMissC = 0; _missChefe = 0; }

    final bool critico = _ataquesChefe % 5 == 0;
    final int base = _chefe.ataque - 4 + _rng.nextInt(9);
    final int dano = critico ? (base * 1.5).round() : base;
    return _AtaqueResult(
        dano: dano,
        tipo: critico ? _TipoAtaque.critico : _TipoAtaque.normal);
  }

  // ─────────────────────────────────────────
  Future<void> _atacar() async {
    if (_animando || _fase != _Fase.batalha) return;
    setState(() => _animando = true);

    // ── Jogador ataca ──
    final rJ = _calcularAtaqueJogador();
    if (rJ.tipo == _TipoAtaque.miss) {
      setState(() => _ultimoEvento = '💨 ERROU!');
      _addLog('Você atacou... mas errou!');
    } else {
      _hpC = (_hpC - rJ.dano).clamp(0, _chefe.hpMax);
      if (rJ.tipo == _TipoAtaque.critico) {
        setState(() => _ultimoEvento = '⚡ CRÍTICO! -${rJ.dano}');
        _addLog('CRÍTICO! Você causou ${rJ.dano} de dano!');
      } else {
        setState(() => _ultimoEvento = '-${rJ.dano}');
        _addLog('Você atacou! Causou ${rJ.dano} de dano.');
      }
      await _doShake();
      setState(() {});
    }

    if (_hpC <= 0) {
      await Future.delayed(const Duration(milliseconds: 400));
      _addLog(_chefe.falaDerrota);
      setState(() { _fase = _Fase.vitoria; _animando = false; });
      return;
    }

    // ── Chefe ataca ──
    await Future.delayed(const Duration(milliseconds: 700));
    final rC = _calcularAtaqueChefe();
    if (rC.tipo == _TipoAtaque.miss) {
      setState(() => _ultimoEvento = '💨 ${_chefe.nome} errou!');
      _addLog('${_chefe.nome} atacou... mas errou!');
    } else {
      _hpJ = (_hpJ - rC.dano).clamp(0, _hpMaxJ);
      if (rC.tipo == _TipoAtaque.critico) {
        setState(() => _ultimoEvento = '⚡ ${_chefe.nome} CRÍTICO! -${rC.dano}');
        _addLog('CRÍTICO! ${_chefe.nome} causou ${rC.dano} de dano!');
      } else {
        setState(() => _ultimoEvento = '${_chefe.nome} -${rC.dano}');
        _addLog('${_chefe.nome} atacou! Você sofreu ${rC.dano} de dano.');
      }
      await _doShake();
      setState(() {});
    }

    if (_hpJ <= 0) {
      _addLog(_chefe.falaVitoria);
      setState(() { _fase = _Fase.derrota; _animando = false; });
      return;
    }

    setState(() { _ultimoEvento = ''; _animando = false; });
  }

  // ─────────────────────────────────────────
  Future<void> _usarItem() async {
    if (_animando || _fase != _Fase.batalha) return;
    setState(() => _animando = true);

    // Café sempre regenera exatamente 30 HP
    final antes = _hpJ;
    _hpJ = (_hpJ + 30).clamp(0, _hpMaxJ);
    final curado = _hpJ - antes;
    setState(() => _ultimoEvento = '☕ +$curado HP');
    _addLog('Usou Café Energético! Recuperou $curado HP.');
    setState(() {});

    await Future.delayed(const Duration(milliseconds: 700));

    // Chefe aproveita para atacar
    final rC = _calcularAtaqueChefe();
    if (rC.tipo == _TipoAtaque.miss) {
      setState(() => _ultimoEvento = '💨 ${_chefe.nome} errou!');
      _addLog('${_chefe.nome} tentou atacar... mas errou!');
    } else {
      _hpJ = (_hpJ - rC.dano).clamp(0, _hpMaxJ);
      if (rC.tipo == _TipoAtaque.critico) {
        setState(() => _ultimoEvento = '⚡ -${rC.dano}');
        _addLog('CRÍTICO! ${_chefe.nome} aproveitou e causou ${rC.dano} de dano!');
      } else {
        setState(() => _ultimoEvento = '-${rC.dano}');
        _addLog('${_chefe.nome} aproveitou e causou ${rC.dano} de dano.');
      }
      await _doShake();
      setState(() {});
    }

    if (_hpJ <= 0) {
      _addLog(_chefe.falaVitoria);
      setState(() { _fase = _Fase.derrota; _animando = false; });
      return;
    }

    setState(() { _ultimoEvento = ''; _animando = false; });
  }

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final amb = ambientesMock.firstWhere((a) => a.id == widget.ambienteId);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0820),
      body: SafeArea(
        child: Column(children: [

          // ── AppBar ──
          Container(
            color: const Color(0xFF100830),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Color(0xFFA78BFA), size: 16),
                onPressed: () => Navigator.pop(context, false),
              ),
              Expanded(
                child: Text(_nomeAmbiente.toUpperCase(),
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 10,
                        color: Colors.white, letterSpacing: 1),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 48),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFF2D1B69)),

          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [

                // ── Arena ──
                Container(
                  height: 200,
                  color: const Color(0xFF080420),
                  child: Stack(children: [
                    // chão
                    Positioned(bottom: 0, left: 0, right: 0,
                        child: Container(height: 32,
                            color: const Color(0xFF1A0E4F))),

                    // Jogador (esq/baixo) com shake
                    Positioned(left: 20, bottom: 20,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (_, __) => Transform.translate(
                          offset: _shake
                              ? Offset(_shakeAnim.value, 0)
                              : Offset.zero,
                          child: _Sprite(
                              emoji: '🧑‍🎓', label: 'VOCÊ'),
                        ),
                      ),
                    ),

                    // Chefe (dir/cima)
                    Positioned(right: 20, top: 20,
                        child: _Sprite(
                            emoji: _chefe.sprite,
                            label: _chefe.nome.toUpperCase())),

                    // Badge do último evento (centro)
                    if (_ultimoEvento.isNotEmpty)
                      Positioned(
                        top: 80, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _ultimoEvento.contains('CRÍTICO')
                                  ? const Color(0xFFE8C840).withOpacity(0.9)
                                  : _ultimoEvento.contains('+')
                                      ? const Color(0xFF48D058).withOpacity(0.9)
                                      : _ultimoEvento.contains('errou')
                                          ? const Color(0xFF5C4F8A).withOpacity(0.9)
                                          : const Color(0xFFE84040).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_ultimoEvento,
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ),

                    // Overlay vitória/derrota
                    if (_fase == _Fase.vitoria)
                      Container(color: const Color(0x55E8C840),
                          child: const Center(
                              child: Text('★ VITÓRIA! ★',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 18,
                                      color: Color(0xFFE8C840))))),
                    if (_fase == _Fase.derrota)
                      Container(color: const Color(0x55E84040),
                          child: const Center(
                              child: Text('✕ DERROTA ✕',
                                  style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 18,
                                      color: Color(0xFFE84040))))),
                  ]),
                ),

                // ── HP Bars ──
                Container(
                  color: const Color(0xFF100830),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Column(children: [
                    HpBar(label: 'VOCÊ',
                        hp: _hpJ, hpMax: _hpMaxJ),
                    const SizedBox(height: 8),
                    HpBar(label: _chefe.nome.toUpperCase(),
                        hp: _hpC, hpMax: _chefe.hpMax),
                  ]),
                ),
                const Divider(height: 1, color: Color(0xFF2D1B69)),

                // ── Log de batalha ──
                Container(
                  height: 110,
                  margin: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0630),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF3D2F6A), width: 2),
                  ),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(10),
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('▸ ${_log[i]}',
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: Colors.white,
                              height: 1.7)),
                    ),
                  ),
                ),

                // ── Legenda de mecânicas ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MecBtn('⚡ Crítico', 'A cada 5 ataques',
                          const Color(0xFFE8C840)),
                      const SizedBox(width: 10),
                      _MecBtn('💨 Miss', 'Até 2 a cada 6',
                          const Color(0xFF5C4F8A)),
                      const SizedBox(width: 10),
                      _MecBtn('☕ Café', '+30 HP fixo',
                          const Color(0xFF48D058)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Ações ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(children: [

                    if (_fase == _Fase.intro)
                      _Btn(label: '▶ INICIAR BATALHA',
                          cor: const Color(0xFF7C3AED),
                          onTap: () =>
                              setState(() => _fase = _Fase.batalha)),

                    if (_fase == _Fase.batalha) ...[
                      Row(children: [
                        Expanded(child: _Btn(
                            label: '⚔ ATACAR',
                            cor: const Color(0xFF5040B0),
                            onTap: _atacar)),
                        const SizedBox(width: 8),
                        Expanded(child: _Btn(
                            label: '☕ CAFÉ (+30HP)',
                            cor: const Color(0xFF1A3010),
                            onTap: _usarItem)),
                      ]),
                      const SizedBox(height: 8),
                      _Btn(label: '↩ FUGIR',
                          cor: const Color(0xFF2A1A1A),
                          onTap: () => Navigator.pop(context, false)),
                    ],

                    if (_fase == _Fase.vitoria) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1000),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFE8C840)
                                  .withOpacity(0.5)),
                        ),
                        child: Column(children: [
                          const Text('RECOMPENSA',
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: Color(0xFFE8C840))),
                          const SizedBox(height: 8),
                          Text('🎁 ${amb.itemRecompensa}',
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('✨ ${amb.skillRecompensa}',
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  color: Color(0xFFA78BFA))),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      _Btn(label: '★ CONTINUAR',
                          cor: const Color(0xFF7C3AED),
                          onTap: () => Navigator.pop(context, true)),
                    ],

                    if (_fase == _Fase.derrota)
                      _Btn(label: '↩ VOLTAR',
                          cor: const Color(0xFF4A1010),
                          onTap: () => Navigator.pop(context, false)),

                    const SizedBox(height: 16),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HpBar atualizado: verde → amarelo (≤50%) → vermelho (≤30)
// ─────────────────────────────────────────────
// OBS: substitui o HpBar.dart inteiro para aplicar a nova lógica de cores
// Copie o conteúdo abaixo para lib/widgets/HpBar.dart

// ─────────────────────────────────────────────
//  Helpers internos
// ─────────────────────────────────────────────
enum _TipoAtaque { normal, critico, miss }

class _AtaqueResult {
  final int dano;
  final _TipoAtaque tipo;
  const _AtaqueResult({required this.dano, required this.tipo});
}

class _Sprite extends StatelessWidget {
  final String emoji, label;
  const _Sprite({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 7,
                color: Color(0xFFD0C8FF))),
        const SizedBox(height: 4),
        Container(
          width: 64, height: 64,
          color: const Color(0xFF1A0E4F),
          child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 34))),
        ),
      ]);
}

class _Btn extends StatelessWidget {
  final String label;
  final Color cor;
  final VoidCallback onTap;
  const _Btn(
      {required this.label, required this.cor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 46,
          decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold))),
        ),
      );
}

class _MecBtn extends StatelessWidget {
  final String titulo, sub;
  final Color cor;
  const _MecBtn(this.titulo, this.sub, this.cor);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cor.withOpacity(0.4)),
        ),
        child: Column(children: [
          Text(titulo,
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 8,
                  color: cor,
                  fontWeight: FontWeight.bold)),
          Text(sub,
              style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 7,
                  color: Color(0xFF5C4F8A))),
        ]),
      );
}