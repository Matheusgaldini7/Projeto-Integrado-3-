import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/audio_manager.dart';
import '../services/battle_helper.dart';
import 'home_screen.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import '../services/chefe_service.dart';
import '../models/chefe.dart';
import '../services/jogador_service.dart';
import '../widgets/app_button.dart';
import 'continue_screen.dart';
import '../models/itens.dart';
import '../data/itens_repository.dart';

class AuditorioScreen extends StatefulWidget {
  final Player player;
  const AuditorioScreen({super.key, required this.player});
  @override
  State<AuditorioScreen> createState() => _AuditorioScreenState();
}

class _AuditorioScreenState extends State<AuditorioScreen> {
  late Player _player;
  late BattleHelper _battle;
  final JogadorService _jogadorService = JogadorService();
  final ChefeService _chefeService = ChefeService();
  Chefe? _chefe;
  bool _isLoading = true;
  static const String idChefe = 'magnifico';
  int _bossHp = 0;
  bool _finalRewardReceived = false;
  String _mode = 'intro';
  late String _storyText;

  Future<void> _carregarDados() async {
    final chefe = await _chefeService.carregarChefe(idChefe);
    if (chefe == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _chefe = chefe;
      _bossHp = chefe.hp;
      _isLoading = false;

      if (_player.inventario.contains('Diploma')) {
        _mode = 'bossDefeated';
        _storyText = 'Você retorna ao Auditório.\n\n'
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
    _storyText =
        '${_player.nickname} chega ao Grande Auditório — Palco da Aprovação.\n\n'
        'O ambiente é vasto e escuro. O único ponto de luz é um holofote central focado no palco.\n\n'
        'As poltronas estão ocupadas por vultos sombrios de estudantes reprovados.';
    _carregarDados();
    AudioManager.playExplorationMusic();
  }

  void _set(VoidCallback fn) => setState(fn);

  void _startCutscene() => _set(() {
        _storyText =
            '${_player.nickname} caminha pelo corredor central.\n\n'
            'Cada passo ecoa no silêncio. Nas fileiras laterais, vultos cinzentos permanecem de cabeça baixa.\n\n'
            'No centro, atrás de uma mesa monumental, está o Reitor das Sombras: Magnífico.';
        _mode = 'cutsceneTwo';
      });

  void _continueCutscene() => _set(() {
        _storyText =
            'Magnífico levanta uma caneta que brilha em vermelho escuro.\n\n'
            'Ele carimba o ar. Um selo flamejante "REPROVADO" surge sobre um dos vultos.\n\n'
            'O estudante se desfaz em partículas de código e desaparece.\n\n'
            '${_player.nickname} para diante do palco.';
        _mode = 'meetRector';
      });

  void _meetRector() => _set(() {
        _storyText =
            'Magnífico: "Mais um aluno..."\n\n'
            '"Vejo que atravessou o campus, sobreviveu aos laboratórios e coletou as assinaturas."\n\n'
            '"Mas aqui, ${_player.nickname}, a lógica é outra. O sistema não aceita erros."';
        _mode = 'dialogueChoice';
      });

  void _present() => _set(() {
        _storyText =
            '${_player.titulo} ${_player.nickname}: "Eu não cometi erros. Aqui estão as provas do meu esforço!"\n\n'
            'Magnífico observa os documentos em silêncio.\n\n'
            'Magnífico: "Provas não significam aprovação. Elas apenas confirmam que você chegou até aqui."\n\n'
            'A toga negra do Reitor se expande cobrindo o palco como névoa escura.';
        _mode = 'beforeBattle';
      });

  void _challenge() => _set(() {
        _storyText =
            '${_player.titulo} ${_player.nickname}: "O seu sistema é falho, e eu vim aqui para encerrar esse ciclo."\n\n'
            'Os vultos nas poltronas levantam a cabeça pela primeira vez.\n\n'
            'Magnífico: "Rebeldia disfarçada de coragem. Já vi isso antes."';
        _mode = 'beforeBattle';
      });

  void _startBattle() {
    AudioManager.playBattleMusic();
    _set(() {
      _mode = 'battle';
      _storyText =
          'Magnífico bate sua caneta gigante no chão.\n\n'
          '"Se deseja sair deste pesadelo, prove que merece a aprovação final."';
    });
  }

  void _attack() => _set(() {
    final res = _battle.processarAtaque(player: _player, chefe: _chefe!);
    
    _bossHp = (_bossHp - res.danoChefe).toInt().clamp(0, _chefe!.hp,);
    _player = _player.copyWith(hp: res.hpPlayerFinal.toInt());
    _jogadorService.salvarJogador(_player);
    _storyText = '${res.mensagemJogador}\n\n${res.mensagemChefe}\nSua vida: ${_player.hp}/${_player.hpMax}';
   
    if (_bossHp <= 0) {
      _mode = 'ending';
      AudioManager.playExplorationMusic();
      _storyText = '${_player.nickname} desfere o golpe final.\n\nMagnífico: "Impossível... o ciclo não deveria ser quebrado..."';
      return;
    } else if (_player.hp <= 0) {
      _lose();
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

  Future<void> _receiveFinalReward() async {

    final novoInventario = List<String>.from(_player.inventario);
    final novoItem = _chefe!.recompensaItem;
    
    if (!novoInventario.contains(novoItem)) {
      novoInventario.add(novoItem);
    }

    int xpBonus = _chefe!.recompensaXp;
    if(
      _player.temSkill(
        "gestao_tempo"
      )
    ){
      const bonusXP = 0.20;
      xpBonus += (
        _chefe!.recompensaXp *
        bonusXP
      ).round();
    }
    final playerAtualizado = _player
        .aplicarRecompensa(
          _chefe!,
          xpCustom: xpBonus,
        )
        .copyWith(
          inventario: novoInventario,
        );

    setState(() {

      _player = playerAtualizado;
      _finalRewardReceived = true;

      _storyText =
          'Vitória! Recompensas recebidas!\n\n'
          '🎁 Item: ${_chefe!.recompensaItem}\n'
          '📈 XP Ganho: $xpBonus';

    });

    await _jogadorService
      .salvarJogador(
          playerAtualizado);

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
              child: Text('Sem itens', style: TextStyle(color: Colors.white)),
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
              leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(item.nome, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                disponivel ? item.descricao : 'Cooldown: ${_battle.turnosParaItem(idItem)} turnos',
                style: const TextStyle(color: Colors.grey),
              ),
              enabled: disponivel,
              onTap: !disponivel ? null : () {
                Navigator.pop(context);
                _usarItem(idItem);
              },
            );
          },
        );
      },
    );
  }

  void _lose() {
    AudioManager.playExplorationMusic();
    _set(() {
      _player = _player.copyWith(hp: 0);
      _bossHp = _chefe!.hp;
      _mode = 'ghost';
      _battle = BattleHelper(bonusAtaque: _player.ataque, skillsAtivas: _player.skills);
      _storyText = 'ERRO FATAL: Seu HP chegou a 0.\n\n👻 VOCÊ ENTROU NO MODO FANTASMA!\n\nSeu código faliu miseravelmente. Você não consegue realizar nenhuma ação aqui. Vá até o Refeitório para se curar!';
    });
    _jogadorService.salvarJogador(_player);
  }

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
        title: const Text('Auditório - Palco da aprovação', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          :Stack(clipBehavior: Clip.none, children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                StatusCard(player: _player, bossLabel: 'Magnífico',
                    bossHp: _bossHp, bossHpMax: _chefe!.hp,
                    showBoss: _mode == 'battle', battle: _battle),
                const SizedBox(height: 8),
                if (_mode == 'battle')
                  SizedBox(
                    height: 240,
                    child: Center(
                      child: BattleBackground(chefe: 'magnifico', genero: _player.genero),
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
                                        'assets/backgrounds/auditorio.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
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
    if (_mode == 'intro') {
      return AppButton(
        label: 'Entrar no Auditório', 
        icon: Icons.door_back_door, 
        onPressed: _startCutscene
      );
    }
    if (_mode == 'ghost') {
      return AppButton(
        label: 'Voltar ao Mapa (Ir ao Refeitório)',
        icon: Icons.map,
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)),
          (route) => false,
        ),
      );
    }
    if (_mode == 'bossDefeated') {
      return AppButton(
        label: 'Entrar no Auditório', 
        icon: Icons.theater_comedy, 
        onPressed: _startCutscene
      );
    }
    if (_mode == 'cutsceneTwo') {
      return AppButton(
        label: 'Continuar', 
        icon: Icons.arrow_forward, 
        onPressed: _continueCutscene
      );
    }
    if (_mode == 'meetRector') {
      return AppButton(
        label: 'Observar Magnífico', 
        icon: Icons.visibility, 
        onPressed: _meetRector
      );
    }
    if (_mode == 'dialogueChoice') {
      return Column(children: [
        AppButton(label: 'Apresentar as assinaturas', icon: Icons.assignment, onPressed: _present),
        AppButton(label: 'Desafiar o sistema', icon: Icons.gavel, onPressed: _challenge),
      ]);
    }
    if (_mode == 'beforeBattle') {
      return AppButton(
        label: 'Iniciar batalha final', 
        icon: Icons.sports_martial_arts, 
        onPressed: _startBattle
      );
    }
    if (_mode == 'battle') {
      return Column(
        children: [

          BattleActions(
            player: _player,
            battle: _battle,
            onAtacar: _attack,
            onUsarItem: (_) => _abrirItens(),
            onFugir: () => Navigator.pop(context),
          ),

        ],
      );
    }
    if (_mode == 'ending') {
      return Column(children: [
        AppButton(
          label: _finalRewardReceived ? 'Diploma recebido 🎓' : 'Receber Diploma',
          icon: Icons.school, 
          onPressed: _finalRewardReceived ? () {} : _receiveFinalReward
        ),
        if (_finalRewardReceived)
          AppButton(
            label: 'Voltar ao início', 
            icon: Icons.home, 
            onPressed: () => Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => const HomeScreen()), 
              (_) => false
            )
          ),
      ]);
    }
    if (_mode == 'lose') {
      return AppButton(
        label: 'Tentar novamente', 
        icon: Icons.restart_alt, 
        onPressed: _lose
      );
    }
    return const SizedBox.shrink();
  }
}