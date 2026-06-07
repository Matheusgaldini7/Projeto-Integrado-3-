import 'package:flutter/material.dart';
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
import '../models/itens.dart';
import '../data/itens_repository.dart';


class H06Screen extends StatefulWidget {
  final Player player;
  const H06Screen({super.key, required this.player});
  @override
  State<H06Screen> createState() => _H06ScreenState();
}

class _H06ScreenState extends State<H06Screen> {
  late Player _player;
  late BattleHelper _battle;
  final JogadorService _jogadorService = JogadorService();
  final ChefeService _chefeService = ChefeService();
  QuizService? _quiz;
  Chefe? _chefe;
  bool _isLoading = true;
  static const String idChefe = 'compilador';
  int _bossHp = 0;
  bool _rewardReceived = false;
  String _mode = 'intro';
  List<Pergunta> _perguntas = [];
  late String _storyText;

  Future<void> _carregarDados() async {
    final chefe = await _chefeService.carregarChefe(idChefe);
    if (chefe == null) { setState(() => _isLoading = false); return; }
    setState(() {
      _chefe = chefe;
      _bossHp = chefe.hp;
      _perguntas = bancoDePerguntas[idChefe] ?? [];
      _isLoading = false;
      if (_player.assinaturas.contains(chefe.assinatura)) {
        _mode = 'bossDefeated';
        _storyText = 'Você retorna ao H06.\n\n${_chefe!.nome}: "Você já provou seu valor, ${_player.titulo}. Não há mais nada para avaliar aqui. Pode seguir em frente."';
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
      _storyText = '${_player.nickname} chega ao prédio H06.\n\nO local parece mais remoto e isolado. O ar é frio, pesado e cortante.\n\nDentro do laboratório, várias telas exibem uma tela azul de logon.';
      _carregarDados();
    }
    AudioManager.playExplorationMusic();
  }

  void _set(VoidCallback fn) => setState(fn);

  void _explore() => _set(() {
    _storyText = '${_player.nickname} avança pelo laboratório do H06.\n\nNas telas, janelas de erro piscam.\n\nPerto de uma bancada, um estudante mexe em um código fonte cheio de comentários.';
    _mode = 'programmerIntro';
  });

  void _talkProgrammer() => _set(() {
    _storyText = 'Programador: "Ei, ${_player.nickname}, você entende de código?\n\nMe dá uma opinião sobre meu projeto? Todas as funções estão comentadas."';
    _mode = 'programmerChoice';
  });

  void _readCode() => _set(() {
    final sk = List<String>.from(_player.skills);
    if (!sk.contains('leitura_codigo')) sk.add('leitura_codigo');
    _player = _player.copyWith(skills: sk);
    _battle = BattleHelper(bonusAtaque: _player.ataque, skillsAtivas: _player.skills);
    _storyText = '${_player.titulo} ${_player.nickname}: "Claro, deixa eu ver seu código."\n\nVocê estuda os comentários e entende melhor a lógica.\n\nHabilidade desbloqueada: Leitura de Código — reduz dano do chefe em 25%.';
    _mode = 'beforeBoss';
  });

  void _ignoreCode() => _set(() {
    _storyText = '${_player.titulo} ${_player.nickname}: "Comentário é perda de tempo."\n\nVocê seguirá sem vantagem.';
    _mode = 'beforeBoss';
  });

  void _meetBoss() => _set(() {
    _storyText = 'O laboratório escurece.\n\nO Compilador surge entre telas azuis e linhas de erro.\n\nO Compilador: "Er_r0: aluno detectado. Iniciando análise...\n\nEscolha como deseja ser avaliado."';
    _mode = 'choice';
  });

  void _startQuiz() {
    _quiz = QuizService(_perguntas);
    setState(() {
      _mode = 'quiz';
      _storyText = 'Você escolheu responder o desafio técnico.\n\nAcerte todas para receber o boletim sem lutar.';
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
          _storyText = 'Build: SUCCESS. O Compilador reconhece sua competência.';
        } else {
          _mode = 'battle';
          AudioManager.playBattleMusic();
          _storyText = 'O Compilador: "Erro detectado. Batalha iniciada."';
        }
      });
    } else { setState(() {}); }
  }

  void _startBattle() {
    AudioManager.playBattleMusic();
    _set(() {
      _mode = 'battle';
      _storyText = '${_player.titulo} ${_player.nickname}: "Não vou deixar você corromper meu progresso."';
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

  void _attack() => _set(() {
    final res = _battle.processarAtaque(player: _player, chefe: _chefe!);
    _bossHp = (_bossHp - res.danoChefe).toInt().clamp(0, _chefe!.hp);
    _player = _player.copyWith(hp: res.hpPlayerFinal.toInt());
    _jogadorService.salvarJogador(_player);
    _storyText = '${res.mensagemJogador}\n\n${res.mensagemChefe}\nSua vida: ${_player.hp}/${_player.hpMax}';
    if (_bossHp <= 0) {
      _mode = 'reward';
      _storyText += '\n\nO Compilador: "Build: SUCCESS. Você passou na revisão."';
      AudioManager.playExplorationMusic();
    } else if (_player.hp <= 0) {
      _player = _player.copyWith(hp: 0);
      _bossHp = _chefe!.hp;
      _mode = 'ghost';
      _battle = BattleHelper(bonusAtaque: _player.ataque, skillsAtivas: _player.skills);
      _storyText = 'ERRO FATAL: Seu HP chegou a 0.\n\n👻 VOCÊ ENTROU NO MODO FANTASMA!\n\nSeu código faliu miseravelmente. Você não consegue realizar nenhuma ação aqui. Vá até o Refeitório para se curar!';
      AudioManager.playExplorationMusic();
      _jogadorService.salvarJogador(_player);
    }
  });

  Future<void> _usarItem(String nome) async {
    final resultado = _battle.processarTurnoComItem(nome, _player, _chefe!);
    setState(() {
      _player = _player.copyWith(hp: resultado.novoHp);
      _storyText = '${resultado.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';
      if (resultado.estaMorto) _lose();
    });
    await _jogadorService.salvarJogador(_player);
  }

  Future<void> _receiveReward() async {
    if (_rewardReceived) return;
    final novasAssinaturas = List<String>.from(_player.assinaturas);
    if (!novasAssinaturas.contains(_chefe!.assinatura)) novasAssinaturas.add(_chefe!.assinatura);
    int xpBonus = _chefe!.recompensaXp;
    if (_player.temSkill("gestao_tempo")) xpBonus += (_chefe!.recompensaXp * 0.20).round();
    final playerAtualizado = _player.aplicarRecompensa(_chefe!, xpCustom: xpBonus).copyWith(assinaturas: novasAssinaturas);
    setState(() {
      _player = playerAtualizado;
      _rewardReceived = true;
      _storyText = 'Vitória! Recompensas recebidas!\n\n🎁 Item: ${_chefe!.recompensaItem}\n📈 XP Ganho: $xpBonus\n✅ Assinatura: ${_chefe!.nome} obtida!';
    });
    await _jogadorService.salvarJogador(_player);
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

  void _goNext() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        leading: _mode == 'battle' ? null : IconButton(icon: const Icon(Icons.home, color: Colors.white), onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false)),
        title: const Text('H06 - Laboratório', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  StatusCard(player: _player, bossLabel: 'O Compilador', bossHp: _bossHp, bossHpMax: _chefe!.hp, showBoss: _mode == 'battle', battle: _battle),
                  const SizedBox(height: 8),
                  if (_mode == 'battle') SizedBox(height: 240, child: Center(child: BattleBackground(chefe: 'compilador', genero: _player.genero))),
                  if (_mode == 'battle') const SizedBox(height: 8),
                  Flexible(
                    child: Card(
                      color: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFF64748B))),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: SingleChildScrollView(child: Text(_storyText, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFE5E7EB))))),
                          if (_mode != 'battle') ...[
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 3, child: SizedBox(height: 170, child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(color: const Color(0xFF020617), child: Image.asset('assets/backgrounds/h06.png', fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink()))))),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: MiniMapa(ambienteAlvo: 'auditorio')),
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
    if (_mode == 'ghost') return AppButton(label: 'Voltar ao Mapa (Ir ao Refeitório)', icon: Icons.map, onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)), (route) => false));
    if (_mode == 'bossDefeated') return AppButton(label: 'Ir para o próximo objetivo', icon: Icons.school, onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ContinueScreen(player: _player)), (route) => false));
    if (_mode == 'intro') return AppButton(label: 'Explorar H06', icon: Icons.computer, onPressed: _explore);
    if (_mode == 'programmerIntro') return AppButton(label: 'Conversar com Programador', icon: Icons.code, onPressed: _talkProgrammer);
    if (_mode == 'programmerChoice') return Column(children: [AppButton(label: 'Claro, deixa eu ver seu código', icon: Icons.visibility, onPressed: _readCode), AppButton(label: 'Comentário é perda de tempo', icon: Icons.block, onPressed: _ignoreCode)]);
    if (_mode == 'beforeBoss') return AppButton(label: 'Enfrentar O Compilador', icon: Icons.memory, onPressed: _meetBoss);
    if (_mode == 'choice') return Column(children: [AppButton(label: 'Responder desafio técnico', icon: Icons.quiz, onPressed: _startQuiz), AppButton(label: 'Batalha por turnos', icon: Icons.sports_martial_arts, onPressed: _startBattle)]);
    if (_mode == 'quiz') {
      final q = _quiz!.perguntaAtual;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(q.texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFFE5E7EB), fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (int i = 0; i < q.opcoes.length; i++) AppButton(label: q.opcoes[i], icon: Icons.arrow_right, onPressed: () => _answerQuestion(i)),
      ]);
    }
    if (_mode == 'battle') return BattleActions(player: _player, battle: _battle, onAtacar: _attack, onUsarItem: (_) => _abrirItens(), onFugir: () => Navigator.pop(context));
    if (_mode == 'reward') return Column(children: [AppButton(label: _rewardReceived ? 'Recompensa recebida ✓' : 'Receber recompensa', icon: Icons.card_giftcard, onPressed: _rewardReceived ? () {} : _receiveReward), if (_rewardReceived) AppButton(label: 'Ir para o próximo objetivo', icon: Icons.theater_comedy, onPressed: _goNext)]);
    if (_mode == 'lose') return AppButton(label: 'Tentar novamente', icon: Icons.restart_alt, onPressed: _lose);
    return const SizedBox.shrink();
  }
}