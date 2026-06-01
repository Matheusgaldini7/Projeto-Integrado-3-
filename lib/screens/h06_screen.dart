import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/battle_helper.dart';
import '../services/player_storage.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import 'continue_screen.dart';

class H06Screen extends StatefulWidget {
  final Player player;
  const H06Screen({super.key, required this.player});
  @override
  State<H06Screen> createState() => _H06ScreenState();
}

class _H06ScreenState extends State<H06Screen> {
  late Player _player;
  late BattleHelper _battle;

  int _bossHp = 160;
  final int _bossHpMax = 160;
  final int _bossAtaque = 28;
  bool _commentsUnlocked = false;
  bool _rewardReceived = false;
  String _mode = 'intro';
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  late String _storyText;

  final List<Map<String, dynamic>> _questions = [
    {'question': 'Para que serve uma variável?',
     'options': ['Armazenar dados durante a execução', 'Desligar o computador', 'Criar imagens automaticamente'],
     'answer': 0},
    {'question': 'O que é uma função?',
     'options': ['Um bloco de código que executa uma tarefa', 'Uma falha do sistema', 'Um tipo de monitor'],
     'answer': 0},
    {'question': 'O que significa erro de sintaxe?',
     'options': ['Erro na escrita do código', 'Erro causado pela internet', 'Problema no teclado'],
     'answer': 0},
    {'question': 'O que é clean code?',
     'options': ['Código limpo, legível e bem organizado', 'Código sem comentários', 'Código que apaga arquivos'],
     'answer': 0},
    {'question': 'Função de um comentário no código?',
     'options': ['Explicar o que o código faz', 'Executar uma instrução extra', 'Diminuir o arquivo'],
     'answer': 0},
  ];

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
    _storyText =
        '${_player.nome} chega ao prédio H06.\n\n'
        'O local parece mais remoto e isolado. O ar é frio, pesado e cortante.\n\n'
        'Dentro do laboratório, várias telas exibem uma tela azul de logon.';
  }

  void _set(VoidCallback fn) => setState(fn);

  void _explore() => _set(() {
        _storyText =
            '${_player.nome} avança pelo laboratório do H06.\n\n'
            'Nas telas, janelas de erro piscam.\n\n'
            'Perto de uma bancada, um estudante mexe em um código fonte cheio de comentários.';
        _mode = 'programmerIntro';
      });

  void _talkProgrammer() => _set(() {
        _storyText =
            'Programador: "Ei, ${_player.nome}, você entende de código?\n\n'
            'Me dá uma opinião sobre meu projeto? Todas as funções estão comentadas."';
        _mode = 'programmerChoice';
      });

  void _readCode() => _set(() {
        _commentsUnlocked = true;
        final sk = List<String>.from(_player.skills);
        if (!sk.contains('Leitura de Código')) sk.add('Leitura de Código');
        _player = _player.copyWith(skills: sk);
        _storyText =
            '${_player.titulo} ${_player.nome}: "Claro, deixa eu ver seu código."\n\n'
            'Você estuda os comentários e entende melhor a lógica.\n\n'
            'Habilidade desbloqueada: Leitura de Código — reduz dano do chefe em 25%.';
        _mode = 'beforeBoss';
      });

  void _ignoreCode() => _set(() {
        _commentsUnlocked = false;
        _storyText = '${_player.titulo} ${_player.nome}: "Comentário é perda de tempo."\n\nVocê seguirá sem vantagem.';
        _mode = 'beforeBoss';
      });

  void _meetBoss() => _set(() {
        _storyText =
            'O laboratório escurece.\n\n'
            'O Compilador surge entre telas azuis e linhas de erro.\n\n'
            'O Compilador: "Er_r0: aluno detectado. Iniciando análise...\n\nEscolha como deseja ser avaliado."';
        _mode = 'choice';
      });

  void _startQuiz() => _set(() {
        _currentQuestion = 0; _correctAnswers = 0; _mode = 'quiz';
        _storyText = 'Você escolheu responder o desafio técnico.\n\nAcerte todas para receber o boletim sem lutar.';
      });

  void _answerQuestion(int i) => _set(() {
        if (i == _questions[_currentQuestion]['answer']) _correctAnswers++;
        _currentQuestion++;
        if (_currentQuestion >= _questions.length) {
          if (_correctAnswers == _questions.length) {
            _bossHp = 0; _mode = 'reward';
            _storyText = 'Build: SUCCESS. O Compilador reconhece sua competência.';
          } else {
            _mode = 'battle';
            _storyText = 'O Compilador: "Erro detectado. Batalha iniciada."';
          }
        }
      });

  void _startBattle() => _set(() {
        _mode = 'battle';
        _storyText = '${_player.titulo} ${_player.nome}: "Não vou deixar você corromper meu progresso."';
      });

  void _attack() => _set(() {
        final r = _battle.atacarJogador();
        _bossHp = (_bossHp - r.dano).clamp(0, _bossHpMax);
        _storyText = r.mensagem;
        if (_bossHp <= 0) {
          _mode = 'reward';
          _storyText += '\n\nO Compilador: "Build: SUCCESS. Você passou na revisão."';
          return;
        }
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_commentsUnlocked ? (_bossAtaque * 0.75).round() : _bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';
        if (_player.hp <= 0) _mode = 'lose';
      });

  void _usarItem(String nome) => _set(() {
        final (msg, cura) = _battle.usarItem(nome);
        _player = _player.copyWith(hp: (_player.hp + cura).clamp(0, _player.hpMax));
        _storyText = '$msg\nSua vida: ${_player.hp}/${_player.hpMax}';
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}';
        if (_player.hp <= 0) _mode = 'lose';
      });

  void _receiveReward() {
    if (_rewardReceived) return;
    final inv = List<String>.from(_player.inventario)..add('IDE');
    final sk = List<String>.from(_player.skills);
    if (!sk.contains('Clean Code')) sk.add('Clean Code');
    final novasFases = _player.fasesVencidas + 1;
    _player = _player.copyWith(
      inventario: inv, skills: sk, fasesVencidas: novasFases, hp: _player.hpMax + 20);
    _set(() {
      _rewardReceived = true;
      _storyText =
          'Recompensa recebida!\n\n🎁 Item: IDE\n✨ Skill: Clean Code\n'
          '⚔️ Bônus ATK: +${_player.bonusAtaque}\n❤️ HP máximo agora: ${_player.hpMax}';
    });
    PlayerStorage.salvar(_player);
  }

  void _lose() => _set(() {
        _player = _player.copyWith(hp: _player.hpMax);
        _bossHp = _bossHpMax; _mode = 'intro';
        _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
        _storyText = 'ERRO FATAL: conhecimento insuficiente.\n\nVocê acorda na entrada do H06.';
      });

  void _goNext() {
    PlayerStorage.salvar(_player);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('H06 — Laboratório de Programação',
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
            StatusCard(player: _player, bossLabel: 'O Compilador',
                bossHp: _bossHp, bossHpMax: _bossHpMax,
                showBoss: _mode == 'battle', battle: _battle),
            const SizedBox(height: 8),
            if (_mode == 'battle')
              SizedBox(
                height: 240,
                child: Center(
                  child: BattleBackground(chefe: 'compilador', genero: _player.genero),
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
                                      'assets/backgrounds/h06.png',
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
                              child: MiniMapa(ambienteAlvo: 'auditorio'),
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
    if (_mode == 'intro') return _btn('Explorar H06', Icons.computer, _explore);
    if (_mode == 'programmerIntro') return _btn('Conversar com Programador', Icons.code, _talkProgrammer);
    if (_mode == 'programmerChoice') return Column(children: [
      _btn('Claro, deixa eu ver seu código', Icons.visibility, _readCode),
      _btn('Comentário é perda de tempo', Icons.block, _ignoreCode),
    ]);
    if (_mode == 'beforeBoss') return _btn('Enfrentar O Compilador', Icons.memory, _meetBoss);
    if (_mode == 'choice') return Column(children: [
      _btn('Responder desafio técnico', Icons.quiz, _startQuiz),
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
      if (_rewardReceived) _btn('Ir para o Auditório', Icons.theater_comedy, _goNext),
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