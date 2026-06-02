import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/audio_manager.dart';
import '../services/battle_helper.dart';
import '../services/player_storage.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import 'continue_screen.dart';

class PolitecnicaScreen extends StatefulWidget {
  final Player player;
  const PolitecnicaScreen({super.key, required this.player});
  @override
  State<PolitecnicaScreen> createState() => _PolitecnicaScreenState();
}

class _PolitecnicaScreenState extends State<PolitecnicaScreen> {
  late Player _player;
  late BattleHelper _battle;

  int _bossHp = 140;
  final int _bossHpMax = 140;
  final int _bossAtaque = 24;
  bool _puzzleBonus = false;
  bool _rewardReceived = false;
  String _mode = 'intro';
  int _currentQuestion = 0;
  int _correctAnswers = 0;

  String _storyText =
      'Você chega à Politécnica.\n\n'
      'O ambiente é tomado por computadores, bancadas de engenharia e quadros cobertos por fórmulas matemáticas.\n\n'
      'O som constante das máquinas cria um clima futurista e desconfortável.';

  final List<Map<String, dynamic>> _questions = [
    {'question': 'Quanto é 2 + 3?', 'options': ['5', '6', '8'], 'answer': 0},
    {'question': 'Qual operação representa uma multiplicação?', 'options': ['+', 'x', '-'], 'answer': 1},
    {'question': 'Resultado de 10 dividido por 2?', 'options': ['2', '5', '10'], 'answer': 1},
    {'question': 'Em lógica, verdadeiro é representado por:', 'options': ['0', '1', '-1'], 'answer': 1},
    {'question': 'O que representa melhor o raciocínio lógico?',
     'options': ['Resolver problemas seguindo etapas', 'Escolher respostas aleatórias', 'Ignorar os dados'],
     'answer': 0},
  ];

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
    AudioManager.playExplorationMusic();
  }

  void _set(VoidCallback fn) => setState(fn);

  void _talkEngineer() => _set(() {
        _storyText =
            'Engenheiro: "Os cálculos são traiçoeiros. '
            'Você pode tentar resolver um enigma agora. Se acertar, terá vantagem contra O Derivador."';
        _mode = 'engineerChoice';
      });

  void _tryPuzzle() => _set(() {
        _storyText =
            '${_player.titulo} ${_player.nome}: "Quero tentar"\n\n'
            'O terminal exibe:\n'
            '"Se uma máquina produz 4 peças por minuto, quantas peças ela produz em 5 minutos?"';
        _mode = 'puzzle';
      });

  void _answerPuzzle(int i) => _set(() {
        _puzzleBonus = i == 1;
        _bossHp = _puzzleBonus ? 110 : 140;
        _storyText = _puzzleBonus
            ? 'Você acertou! O Derivador começará enfraquecido.'
            : 'Você errou. Seguirá sem vantagem.';
        _mode = 'beforeBoss';
      });

  void _fightDirectly() => _set(() {
        _storyText = 'Engenheiro: "Coragem sem preparo também é uma fórmula."\n\nO Derivador aguarda.';
        _mode = 'beforeBoss';
      });

  void _meetBoss() => _set(() {
        _storyText =
            'O Derivador: "Você superou a primeira avaliação, mas agora está diante da verdadeira barreira matemática.\n\n'
            'Escolha como deseja ser avaliado."';
        _mode = 'choice';
      });

  void _startQuiz() => _set(() {
        _currentQuestion = 0; _correctAnswers = 0; _mode = 'quiz';
        _storyText = '${_player.titulo} ${_player.nome}: "Vou ganhar de você em seu próprio jogo"\n\nAcerte todas para receber a Assinatura da Lógica.';
      });

  void _answerQuestion(int i) => _set(() {
        if (i == _questions[_currentQuestion]['answer']) _correctAnswers++;
        _currentQuestion++;
        if (_currentQuestion >= _questions.length) {
          if (_correctAnswers == _questions.length) {
            _bossHp = 0;
            _mode = 'reward';
            AudioManager.playExplorationMusic();
            _storyText = 'Você acertou tudo! O Derivador entrega o boletim sem lutar.';
          } else {
            _mode = 'battle';
            AudioManager.playBattleMusic();
            _storyText = 'O Derivador: "A lógica falhou. Agora veremos sua resistência."';
          }
        }
      });

  void _startBattle() {
    AudioManager.playBattleMusic();
    _set(() {
      _mode = 'battle';
      _storyText = '${_player.titulo} ${_player.nome}: "Prepare-se."\n\nAs fórmulas no quadro começam a brilhar.';
    });
  }

  void _attack() => _set(() {
        final r = _battle.atacarJogador();
        int dano = r.dano;
        if (_puzzleBonus && r.tipo != TipoAtaque.miss) dano = (dano * 1.2).round();
        _bossHp = (_bossHp - dano).clamp(0, _bossHpMax);
        _storyText = '${r.mensagem}${_puzzleBonus && r.tipo != TipoAtaque.miss ? " (bônus lógica!)" : ""}';
        if (_bossHp <= 0) {
          _mode = 'reward';
          AudioManager.playExplorationMusic();
          _storyText += '\n\nO Derivador: "Sua solução foi... elegante."';
          return;
        }
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_puzzleBonus ? (_bossAtaque * 0.6).round() : _bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';
        if (_player.hp <= 0) {
          _mode = 'lose';
          AudioManager.playExplorationMusic();
        }
      });

  void _usarItem(String nome) => _set(() {
        final (msg, cura) = _battle.usarItem(nome);
        _player = _player.copyWith(hp: (_player.hp + cura).clamp(0, _player.hpMax));
        _storyText = '$msg\nSua vida: ${_player.hp}/${_player.hpMax}';
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}';
        if (_player.hp <= 0) {
          _mode = 'lose';
          AudioManager.playExplorationMusic();
        }
      });

  void _receiveReward() {
    if (_rewardReceived) return;
    final inv = List<String>.from(_player.inventario)..add('Calculadora');
    final sk = List<String>.from(_player.skills)..add('Raciocínio Lógico');
    final novasFases = _player.fasesVencidas + 1;
    _player = _player.copyWith(
      inventario: inv, skills: sk, fasesVencidas: novasFases, hp: _player.hpMax + 20);
    _set(() {
      _rewardReceived = true;
      _storyText =
          'Recompensa recebida!\n\n🎁 Item: Calculadora\n✨ Skill: Raciocínio Lógico\n'
          '⚔️ Bônus ATK: +${_player.bonusAtaque}\n❤️ HP máximo agora: ${_player.hpMax}';
    });
    PlayerStorage.salvar(_player);
  }

  void _lose() {
    AudioManager.playExplorationMusic();
    _set(() {
      _player = _player.copyWith(hp: _player.hpMax);
      _bossHp = _bossHpMax;
      _mode = 'intro';
      _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
      _storyText = 'Você foi derrotado.\n\nAbre os olhos na entrada da Politécnica.';
    });
  }

  void _goNext() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => ContinueScreen(player: _player, destinoOverride: 'refeitorio')));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Politécnica — Laboratório da Lógica',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            StatusCard(player: _player, bossLabel: 'O Derivador',
                bossHp: _bossHp, bossHpMax: _bossHpMax,
                showBoss: _mode == 'battle', battle: _battle),
            const SizedBox(height: 8),
            if (_mode == 'battle')
              SizedBox(
                height: 240,
                child: Center(
                  child: BattleBackground(chefe: 'derivador', genero: _player.genero),
                ),
              ),
            if (_mode == 'battle') const SizedBox(height: 8),
            Flexible(
              child: Card(
                color: const Color(0xFF111827),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF64748B))),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: SingleChildScrollView(
                      child: Text(_storyText, textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16, height: 1.5,
                              color: Color(0xFFE5E7EB))),
                    )),
                    if (_mode != 'battle') ...[
                      const SizedBox(height: 10),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 170,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    color: const Color(0xFF020617),
                                    child: Image.asset(
                                      'assets/backgrounds/ct.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: MiniMapa(ambienteAlvo: 'refeitorio'),
                            ),
                          ],
                        ),
                    ],
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildActions(),
          ]),
        ),
      ]),
    );
  }

  Widget _buildActions() {
    if (_mode == 'intro') return _btn('Explorar laboratório', Icons.precision_manufacturing, _talkEngineer);
    if (_mode == 'engineerChoice') return Column(children: [
      _btn('Quero tentar resolver', Icons.psychology, _tryPuzzle),
      _btn('Prefiro lutar direto', Icons.sports_martial_arts, _fightDirectly),
    ]);
    if (_mode == 'puzzle') return Column(children: [
      _btn('10 peças', Icons.arrow_right, () => _answerPuzzle(0)),
      _btn('20 peças', Icons.arrow_right, () => _answerPuzzle(1)),
      _btn('25 peças', Icons.arrow_right, () => _answerPuzzle(2)),
    ]);
    if (_mode == 'beforeBoss') return _btn('Enfrentar O Derivador', Icons.calculate, _meetBoss);
    if (_mode == 'choice') return Column(children: [
      _btn('Responder perguntas', Icons.quiz, _startQuiz),
      _btn('Batalha por turnos', Icons.sports_martial_arts, _startBattle),
    ]);
    if (_mode == 'quiz') {
      final q = _questions[_currentQuestion];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(q['question'], textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFFE5E7EB),
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (int i = 0; i < (q['options'] as List).length; i++)
          _btn(q['options'][i], Icons.arrow_right, () => _answerQuestion(i)),
      ]);
    }
    if (_mode == 'battle') return BattleActions(
      player: _player, battle: _battle,
      onAtacar: _attack, onUsarItem: _usarItem,
      onFugir: () => Navigator.pop(context),
    );
    if (_mode == 'reward') return Column(children: [
      _btn(_rewardReceived ? 'Recompensa recebida ✓' : 'Receber recompensa',
          Icons.card_giftcard, _rewardReceived ? () {} : _receiveReward),
      if (_rewardReceived) _btn('Ir para o Refeitório', Icons.restaurant, _goNext),
    ]);
    if (_mode == 'lose') return _btn('Tentar novamente', Icons.restart_alt, _lose);
    return const SizedBox.shrink();
  }

  Widget _btn(String t, IconData i, VoidCallback fn) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(width: double.infinity, height: 46,
          child: ElevatedButton.icon(
            onPressed: fn, icon: Icon(i),
            label: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ),
      );
}