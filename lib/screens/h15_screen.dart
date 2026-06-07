import 'package:flutter/material.dart';
import 'package:projeto/models/itens.dart';
import '../models/player.dart';
import '../services/audio_manager.dart';
import '../services/battle_helper.dart';
import 'home_screen.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import 'continue_screen.dart';
import '../data/perguntas_data.dart';
import '../services/chefe_service.dart';
import '../models/chefe.dart';
import '../services/jogador_service.dart';
import '../services/quiz_service.dart';
import '../widgets/app_button.dart';
import '../data/itens_repository.dart';

class H15Screen extends StatefulWidget {
  final Player player;
  const H15Screen({super.key, required this.player});
  @override
  State<H15Screen> createState() => _H15ScreenState();
}

class _H15ScreenState extends State<H15Screen> {
  late Player _player;
  late BattleHelper _battle;
  final JogadorService _jogadorService = JogadorService();
  final ChefeService _chefeService = ChefeService();
  QuizService? _quiz;
  Chefe? _chefe;
  bool _isLoading = true;
  static const String idChefe = 'maligno';
  int _bossHp = 0;
  String _mode = 'npcIntro';
  bool _rewardReceived = false;
  int _step = 0;
  List<Pergunta> _perguntas = [];

  String _storyText = 'Você acorda desnorteado em um banco próximo ao Bloco H15.\n\n'
      'O campus está vazio, escuro e silencioso. As luzes piscam ao longe.\n\n'
      'À sua frente, uma figura encapuzada observa em silêncio.';

  Future<void> _carregarDados() async {
    final chefe = await _chefeService.carregarChefe(idChefe);

    if (chefe == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _chefe = chefe;
      _bossHp = chefe.hp;
      _perguntas = bancoDePerguntas[idChefe] ?? [];
      _isLoading = false;

      if (_player.assinaturas.contains(chefe.assinatura)) {
        _mode = 'bossDefeated';
        _storyText = 'Você retorna ao H15.\n\n'
            '${_chefe!.nome}: "Você já provou seu valor, ${_player.titulo}. '
            'Não há mais nada para avaliar aqui. Pode seguir em frente."';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _battle = BattleHelper(bonusAtaque: _player.ataque, skillsAtivas: _player.skills);


    if (_player.hp <= 0) {
      _mode = 'ghost';
      _storyText = '👻 MODO FANTASMA ATIVO!\n\nSua energia está zerada. Você não pode explorar ou batalhar neste estado. Vá imediatamente ao Refeitório para se curar.';
      _isLoading = false;
    } else {
      _storyText = 'O prédio H15 parece silencioso...';
      _carregarDados();
    }
    AudioManager.playExplorationMusic();
  }

  void _set(VoidCallback fn) => setState(fn);

  void _askName() => _set(() => _storyText = '${_player.titulo} ${_player.nickname}: "Qual o seu nome?"\n\n'
      'Guardião: "Meu nome não pode ser dito aqui. Por enquanto, apenas me chame de Guardião do Banco."');

  void _askObjective() => _set(() => _storyText = 'Guardião: "Você precisa derrotar os chefes espalhados pelo campus e coletar os boletins.\n\n'
      'O primeiro obstáculo está no H15: Maligno."');

  void _askLocation() => _set(() => _storyText = 'Guardião: "Você está na PUC-Campinas... mas não exatamente na mesma que conhecia.\n\n'
      'Este campus reflete seus desafios acadêmicos.');

  void _continueAfterNpc() => _set(() {
        _storyText = 'Guardião: "Comece pelo H15."\n\n'
            '"O Maligno decidirá se você tem base suficiente para continuar."\n\n'
            'O caminho até o bloco parece vazio. Mesmo assim, você sente que algo observa seus passos.';
        _mode = 'explore';
      });

  void _explore() => _set(() {
        _step++;
        if (_step == 1) {
          _storyText = 'Você entra em uma sala aleatória do H15.\n\n'
              'As cadeiras estão fora do lugar, o projetor está ligado, mas não há ninguém. '
              'Na parede: "Avaliação pendente".';
        } else if (_step == 2) {
          _storyText = 'No corredor, uma lixeira caída. Papéis espalhados com provas e códigos incompletos.\n\n'
              'Uma frase escrita à mão:\n"O subsolo guarda aquilo que foi recusado."';
        } else {
          _storyText = 'Você desce até o subsolo do H15.\n\n'
              'Os computadores estão ligados, mas nenhuma pessoa aparece.\n\n'
              'De repente, um barulho metálico ecoa no fundo do corredor.';
          _mode = 'noiseChoice';
        }
      });

  void _hide() {
    AudioManager.playBattleMusic();
    _set(() {
      _storyText = 'Você tenta se esconder atrás de uma mesa.\n\n'
          'Maligno: "Achou mesmo que poderia se esconder dentro da minha própria avaliação?\n\n'
          'Agora será obrigado a enfrentá-lo."';
      _mode = 'battle';
    });
  }

  void _follow() => _set(() {
        _storyText = 'Maligno: "Então você me encontrou.\n\n'
            'Como pretende ser avaliado?"';
        _mode = 'choice';
      });

  void _startQuiz() {
    _quiz = QuizService(_perguntas);
    setState(() {
      _mode = 'quiz';
      _storyText = 'Você escolheu responder às perguntas do Maligno.\n\n'
                  'Acerte todas para receber o boletim sem lutar.';
    });
  }

  void _answerQuestion(int i) {
    final acabou = _quiz!.responder(i);
    
    if (acabou) {
      setState(() {
        if (_quiz!.venceu) {
          _bossHp = 0;
          _mode = 'reward';
          AudioManager.playExplorationMusic();

          _storyText = 'Você acertou todas as perguntas!\n\n'
                'Maligno reconhece seu conhecimento e entrega o boletim sem lutar.';
        } else {
          _mode = 'battle';
          AudioManager.playBattleMusic();
          _storyText = 'Você errou pelo menos uma pergunta.\n\n'
                'Maligno: "Resposta insuficiente. Agora você será testado."';
        }
      });
    } else {
      setState(() {}); 
    }
  }

  void _startBattle() {
    AudioManager.playBattleMusic();
    _set(() {
      _mode = 'battle';
      _storyText = '${_player.titulo} ${_player.nickname}: "Prepare-se."\n\n'
          'Maligno: "Interessante... vamos ver se você aguenta até o final."';
    });
  }

 void _abrirItens() {

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (_) {

        final itens = _player.inventario
            .map((nome) => ItensRepository.getItem(nome))
            .where((item) => item != null)
            .cast<ItemBatalha>()
            .toList();
        
        if (itens.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'Sem itens',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: itens.length,
          itemBuilder: (_, index) {

            final item = itens[index]; 
         
            final idItem = item.nome; 

            final disponivel = _battle.itemDisponivel(idItem);

            return ListTile(
              leading: Text(
                item.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                item.nome,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                disponivel ? item.descricao : 'Cooldown: ${_battle.turnosParaItem(idItem)} turnos',
                style: const TextStyle(color: Colors.grey),
              ),
              enabled: disponivel,
              onTap: !disponivel
                  ? null
                  : () {
                      Navigator.pop(context);
                      _usarItem(idItem);
                    },
            );
          },
        );
      },
    );
  }

  void _attack() => _set(() {
    final res = _battle.processarAtaque(player: _player, chefe: _chefe!);

    _bossHp = (_bossHp - res.danoChefe).toInt().clamp(0, _chefe!.hp);
    _player = _player.copyWith(hp: res.hpPlayerFinal.toInt());
    _jogadorService.salvarJogador(_player);
    _storyText = '${res.mensagemJogador}\n\n${res.mensagemChefe}\nSua vida: ${_player.hp}/${_player.hpMax}';

    if (_bossHp <= 0) {
      _mode = 'reward';
      _storyText += '\n\nMaligno: "Impressionante… você passou pela minha avaliação."';
      AudioManager.playExplorationMusic();
    } else if (_player.hp <= 0) {
      _mode = 'lose';
      _storyText += '\n\nMaligno: "Insuficiente. Volte quando estiver preparado."';
      AudioManager.playExplorationMusic();
    }
  });

  void _usarItem(String nome) async {
    final resultado = _battle.processarTurnoComItem(nome, _player, _chefe!);

    setState(() {
      _player = _player.copyWith(hp: resultado.novoHp);
      _storyText = '${resultado.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';

      if (resultado.estaMorto) {
        _mode = 'lose';
        AudioManager.playExplorationMusic();
      }
    });
    await _jogadorService.salvarJogador(_player);
  }

  Future<void> _receiveReward() async {
    if (_rewardReceived) return;

    final novasAssinaturas = List<String>.from(_player.assinaturas);

    if (!novasAssinaturas.contains(_chefe!.assinatura)) {
      novasAssinaturas.add(_chefe!.assinatura);
    }

    final novoInventario = List<String>.from(_player.inventario);
    final novoItem = _chefe!.recompensaItem;
    
    if (!novoInventario.contains(novoItem)) {
      novoInventario.add(novoItem);
    }

    int xpBonus = _chefe!.recompensaXp;

    if (_player.temSkill("gestao_tempo")) {
      xpBonus += (_chefe!.recompensaXp * 0.20).round();
    }

    final playerAtualizado = _player
        .aplicarRecompensa(
          _chefe!,
          xpCustom: xpBonus,
        )
        .copyWith(
          assinaturas: novasAssinaturas,
          inventario: novoInventario,
        );

    setState(() {
      _player = playerAtualizado;
      _rewardReceived = true;

      _storyText =
          'Vitória! Recompensas recebidas!\n\n'
          '🎁 Item: ${_chefe!.recompensaItem}\n'
          '📈 XP Ganho: $xpBonus\n'
          '✅ Assinatura: ${_chefe!.nome} obtida!';
    });

    await _jogadorService.salvarJogador(_player);
  }

  void _lose() {
    AudioManager.playExplorationMusic();
    _set(() {
      _player = _player.copyWith(hp: 0);
      _bossHp = _chefe!.hp;
      _mode = 'ghost';
      _step = 0;
      _battle = BattleHelper(bonusAtaque: _player.ataque, skillsAtivas: _player.skills,);
      _storyText = 'ERRO FATAL: Seu HP chegou a 0.\n\n👻 VOCÊ ENTROU NO MODO FANTASMA!\n\nSeu código faliu miseravelmente. Você não consegue realizar nenhuma ação aqui. Vá até o Refeitório para se curar!';
    });
    _jogadorService.salvarJogador(_player);
  }

  void _goNext() => Navigator.pushReplacement(context, 
    MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
      leading: _mode == 'battle' 
          ? null 
          : IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
      title: const Text('Nome do Bloco', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      backgroundColor: const Color(0xFF111827),
      automaticallyImplyLeading: false,
    ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(clipBehavior: Clip.none, children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(children: [
                  StatusCard(
                      player: _player,
                      bossLabel: _chefe!.nome,
                      bossHp: _bossHp,
                      bossHpMax: _chefe!.hp,
                      showBoss: _mode == 'battle',
                      battle: _battle),
                  const SizedBox(height: 8),
                  if (_mode == 'battle')
                    SizedBox(
                        height: 240,
                        child: Center(child: BattleBackground(chefe: 'maligno', genero: _player.genero))),
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
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(_storyText,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFE5E7EB))),
                            ),
                          ),
                          if (_mode != 'battle') ...[
                            const SizedBox(height: 10),
                            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                    height: 170,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                            color: const Color(0xFF020617),
                                            child: Image.asset('assets/backgrounds/h15_img.png',
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, _, _) => const SizedBox.shrink())))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: MiniMapa(ambienteAlvo: 'politecnica')),
                            ]),
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
    if (_mode == 'bossDefeated') {
      return AppButton(
        label: 'Ir para o próximo objetivo', 
        icon: Icons.school, 
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => ContinueScreen(player: _player), 
            ),
            (route) => false,
          );
        }
      );
    }

    if (_mode == 'ghost') {
      return AppButton(
        label: 'Voltar ao Mapa (Ir ao Refeitório)',
        icon: Icons.map,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)),
            (route) => false,
          );
        },
      );
    }

    if (_mode == 'npcIntro') {
      return Column(children: [
        AppButton(label: 'Perguntar o nome', icon: Icons.person_search, onPressed: _askName),
        AppButton(label: 'Perguntar objetivo', icon: Icons.flag, onPressed: _askObjective),
        AppButton(label: 'Perguntar onde estou', icon: Icons.location_on, onPressed: _askLocation),
        AppButton(label: 'Continuar', icon: Icons.arrow_forward, onPressed: _continueAfterNpc)
      ]);
    }
    if (_mode == 'explore') {
      return AppButton(label: 'Explorar o H15', icon: Icons.explore, onPressed: _explore);
    }
    if (_mode == 'noiseChoice') {
      return Column(children: [
        AppButton(label: 'Se esconder', icon: Icons.visibility_off, onPressed: _hide),
        AppButton(label: 'Ir atrás do barulho', icon: Icons.hearing, onPressed: _follow)
      ]);
    }
    if (_mode == 'choice') {
      return Column(children: [
        AppButton(label: 'Responder perguntas', icon: Icons.quiz, onPressed: _startQuiz),
        AppButton(label: 'Batalha por turnos', icon: Icons.sports_martial_arts, onPressed: _startBattle)
      ]);
    }
    if (_mode == 'quiz') {
      final q = _quiz!.perguntaAtual;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(q.texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFFE5E7EB), fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (int i = 0; i < q.opcoes.length; i++) 
          AppButton(
            label: q.opcoes[i], 
            icon: Icons.arrow_right, 
            onPressed: () => _answerQuestion(i)
          ),
      ]);
    }
    if (_mode == 'battle') {
      return BattleActions(
          player: _player,
          battle: _battle,
          onAtacar: _attack,
          onUsarItem: (p) => _abrirItens(),
          onFugir: () => Navigator.pop(context));
    }
    if (_mode == 'reward') {
      return Column(children: [
        AppButton(
          label: _rewardReceived ? 'Recompensa recebida ✓' : 'Receber recompensa', 
          icon: Icons.card_giftcard,
          onPressed: _rewardReceived ? () {} : _receiveReward
        ),
        if (_rewardReceived) 
          AppButton(label: 'Ir para o próximo objetivo', icon: Icons.school, onPressed: _goNext)
      ]);
    }
    if (_mode == 'lose') {
      return AppButton(label: 'Tentar novamente', icon: Icons.restart_alt, onPressed: _lose);
    }
    return const SizedBox.shrink();
  }
}
