import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/battle_helper.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import 'refeitorio_screen.dart';

class H15Screen extends StatefulWidget {
  final Player player;
  const H15Screen({super.key, required this.player});
  @override
  State<H15Screen> createState() => _H15ScreenState();
}

class _H15ScreenState extends State<H15Screen> {
  late Player _player;
  late BattleHelper _battle;

  int _bossHp = 120;
  final int _bossHpMax = 120;
  final int _bossAtaque = 18;
  String _mode = 'npcIntro';
  bool _rewardReceived = false;
  int _currentQuestion = 0;
  int _correctAnswers = 0;
  int _step = 0;

  String _storyText =
      'Você acorda desnorteado em um banco próximo ao Bloco H15.\n\n'
      'O campus está vazio, escuro e silencioso. As luzes piscam ao longe.\n\n'
      'À sua frente, uma figura encapuzada observa em silêncio.';

  final List<Map<String, dynamic>> _questions = [
    {'question': 'O que é um sistema de informação?',
     'options': ['Um conjunto de pessoas, processos e tecnologia para tratar informações', 'Apenas um computador ligado à internet', 'Um jogo instalado no celular'],
     'answer': 0},
    {'question': 'Qual destes é um exemplo de dado?',
     'options': ['Uma informação analisada', 'O número 25 registrado em uma tabela', 'Uma decisão tomada por um gerente'],
     'answer': 1},
    {'question': 'Para que serve um banco de dados?',
     'options': ['Guardar, organizar e consultar informações', 'Melhorar o sinal do Wi-Fi', 'Aumentar o brilho da tela'],
     'answer': 0},
    {'question': 'O que é programação?',
     'options': ['Criar instruções para o computador executar tarefas', 'Montar fisicamente um computador', 'Apenas usar aplicativos prontos'],
     'answer': 0},
    {'question': 'Qual é uma função da TI nas empresas?',
     'options': ['Apoiar processos, decisões e organização de dados', 'Substituir totalmente todas as pessoas', 'Servir apenas para entretenimento'],
     'answer': 0},
  ];

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
  }

  void _set(VoidCallback fn) => setState(fn);

  void _askName() => _set(() => _storyText =
      '${_player.titulo} ${_player.nome}: "Qual o seu nome?"\n\n'
      'Guardião: "Meu nome não pode ser dito aqui. Por enquanto, apenas me chame de Guardião do Banco."');

  void _askObjective() => _set(() => _storyText =
      'Guardião: "Você precisa derrotar os chefes espalhados pelo campus e coletar os boletins.\n\n'
      'O primeiro obstáculo está no H15: Maligno."');

  void _askLocation() => _set(() => _storyText =
      'Guardião: "Você está na PUC-Campinas... mas não exatamente na mesma que conhecia.\n\n'
      'Este campus reflete seus desafios acadêmicos."');

  void _continueAfterNpc() => _set(() {
        _storyText =
            'Guardião: "Comece pelo H15."\n\n'
            '"O Maligno decidirá se você tem base suficiente para continuar."\n\n'
            'O caminho até o bloco parece vazio. Mesmo assim, você sente que algo observa seus passos.';
        _mode = 'explore';
      });

  void _explore() => _set(() {
        _step++;
        if (_step == 1) {
          _storyText =
              'Você entra em uma sala aleatória do H15.\n\n'
              'As cadeiras estão fora do lugar, o projetor está ligado, mas não há ninguém. '
              'Na parede: "Avaliação pendente".';
        } else if (_step == 2) {
          _storyText =
              'No corredor, uma lixeira caída. Papéis espalhados com provas e códigos incompletos.\n\n'
              'Uma frase escrita à mão:\n"O subsolo guarda aquilo que foi recusado."';
        } else {
          _storyText =
              'Você desce até o subsolo do H15.\n\n'
              'Os computadores estão ligados, mas nenhuma pessoa aparece.\n\n'
              'De repente, um barulho metálico ecoa no fundo do corredor.';
          _mode = 'noiseChoice';
        }
      });

  void _hide() => _set(() {
        _storyText =
            'Você tenta se esconder atrás de uma mesa.\n\n'
            'Maligno: "Achou mesmo que poderia se esconder dentro da minha própria avaliação?\n\n'
            'Agora será obrigado a enfrentá-lo."';
        _mode = 'battle';
      });

  void _follow() => _set(() {
        _storyText =
            'Maligno: "Então você me encontrou.\n\n'
            'Como pretende ser avaliado?"';
        _mode = 'choice';
      });

  void _startQuiz() => _set(() {
        _currentQuestion = 0;
        _correctAnswers = 0;
        _mode = 'quiz';
        _storyText =
            'Você escolheu responder às perguntas do Maligno.\n\n'
            'Acerte todas para receber o boletim sem lutar.';
      });

  void _answerQuestion(int idx) => _set(() {
        if (idx == _questions[_currentQuestion]['answer']) _correctAnswers++;
        _currentQuestion++;
        if (_currentQuestion >= _questions.length) {
          if (_correctAnswers == _questions.length) {
            _bossHp = 0;
            _mode = 'reward';
            _storyText =
                'Você acertou todas as perguntas!\n\n'
                'Maligno reconhece seu conhecimento e entrega o boletim sem lutar.';
          } else {
            _mode = 'battle';
            _storyText =
                'Você errou pelo menos uma pergunta.\n\n'
                'Maligno: "Resposta insuficiente. Agora você será testado."';
          }
        }
      });

  void _startBattle() => _set(() {
        _mode = 'battle';
        _storyText =
            '${_player.titulo} ${_player.nome}: "Prepare-se."\n\n'
            'Maligno: "Interessante... vamos ver se você aguenta até o final."';
      });

  void _attack() => _set(() {
        final r = _battle.atacarJogador();
        _bossHp = (_bossHp - r.dano).clamp(0, _bossHpMax);
        _storyText = r.mensagem;
        if (_bossHp <= 0) {
          _mode = 'reward';
          _storyText += '\n\nMaligno: "Impressionante… você passou pela minha avaliação."';
          return;
        }
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';
        if (_player.hp <= 0) {
          _mode = 'lose';
          _storyText += '\n\nMaligno: "Insuficiente. Volte quando estiver preparado."';
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
        if (_player.hp <= 0) _mode = 'lose';
      });

  void _receiveReward() {
    if (_rewardReceived) return;
    final inv = List<String>.from(_player.inventario)..add('Caneta da Aprovação');
    final sk = List<String>.from(_player.skills)..add('Argumentação Final');
    final novasFases = _player.fasesVencidas + 1;
    _player = _player.copyWith(
      inventario: inv, skills: sk, fasesVencidas: novasFases,
      hp: _player.hpMax + 20,
    );
    _set(() {
      _rewardReceived = true;
      _storyText =
          'Recompensa recebida!\n\n'
          '🎁 Item: Caneta da Aprovação\n'
          '✨ Skill: Argumentação Final\n'
          '⚔️ Bônus ATK: +${_player.bonusAtaque}\n'
          '❤️ HP máximo agora: ${_player.hpMax}';
    });
  }

  void _lose() => _set(() {
        _player = _player.copyWith(hp: _player.hpMax);
        _bossHp = _bossHpMax;
        _mode = 'npcIntro';
        _step = 0;
        _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
        _storyText = 'Você perdeu.\n\nVocê abre os olhos e se encontra novamente no H15.';
      });

  void _goNext() => Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => RefeitorioScreen(player: _player, voltouDeH15: true)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('H15 — Bloco Infernal',
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
            StatusCard(
              player: _player,
              bossLabel: 'Maligno',
              bossHp: _bossHp,
              bossHpMax: _bossHpMax,
              showBoss: _mode == 'battle',
              battle: _battle,
            ),
            const SizedBox(height: 8),
            if (_mode == 'battle')
              SizedBox(
                height: 240,
                child: Center(
                  child: BattleBackground(chefe: 'maligno', genero: _player.genero),
                ),
              ),
            if (_mode == 'battle') const SizedBox(height: 8),
            Flexible(
              child: Card(
                color: const Color(0xFF111827),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFF64748B)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(_storyText,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  fontSize: 16, height: 1.5,
                                  color: Color(0xFFE5E7EB))),
                        ),
                      ),
                      if (_mode != 'battle') ...[
                        const SizedBox(height: 10),
                        Center(
                          child: SizedBox(
                            height: 170,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/backgrounds/h15_img.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildActions(),
          ]),
        ),
        if (_mode != 'battle')
          Positioned(
            bottom: 120,
            right: 14,
            child: MiniMapa(ambienteAlvo: 'refeitorio'),
          ),
      ]),
    );
  }

  Widget _buildActions() {
    if (_mode == 'npcIntro') return Column(children: [
      _btn('Perguntar o nome', Icons.person_search, _askName),
      _btn('Perguntar objetivo', Icons.flag, _askObjective),
      _btn('Perguntar onde estou', Icons.location_on, _askLocation),
      _btn('Continuar', Icons.arrow_forward, _continueAfterNpc),
    ]);
    if (_mode == 'explore') return _btn('Explorar o H15', Icons.explore, _explore);
    if (_mode == 'noiseChoice') return Column(children: [
      _btn('Se esconder', Icons.visibility_off, _hide),
      _btn('Ir atrás do barulho', Icons.hearing, _follow),
    ]);
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
      if (_rewardReceived)
        _btn('Ir para o Refeitório', Icons.restaurant, _goNext),
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
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ),
      );
}

