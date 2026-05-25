import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/battle_helper.dart';
import '../widgets/battle_background.dart';
import '../widgets/battle_actions.dart';
import '../widgets/status_card.dart';
import '../widgets/mini_mapa.dart';
import 'home_screen.dart';

class AuditorioScreen extends StatefulWidget {
  final Player player;
  const AuditorioScreen({super.key, required this.player});
  @override
  State<AuditorioScreen> createState() => _AuditorioScreenState();
}

class _AuditorioScreenState extends State<AuditorioScreen> {
  late Player _player;
  late BattleHelper _battle;

  int _bossHp = 220;
  final int _bossHpMax = 220;
  final int _bossAtaque = 35;
  bool _finalRewardReceived = false;
  String _mode = 'intro';
  late String _storyText;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
    _storyText =
        '${_player.nome} chega ao Grande Auditório — Palco da Aprovação.\n\n'
        'O ambiente é vasto e escuro. O único ponto de luz é um holofote central focado no palco.\n\n'
        'As poltronas estão ocupadas por vultos sombrios de estudantes reprovados.';
  }

  void _set(VoidCallback fn) => setState(fn);

  void _startCutscene() => _set(() {
        _storyText =
            '${_player.nome} caminha pelo corredor central.\n\n'
            'Cada passo ecoa no silêncio. Nas fileiras laterais, vultos cinzentos permanecem de cabeça baixa.\n\n'
            'No centro, atrás de uma mesa monumental, está o Reitor das Sombras: Magnífico.';
        _mode = 'cutsceneTwo';
      });

  void _continueCutscene() => _set(() {
        _storyText =
            'Magnífico levanta uma caneta que brilha em vermelho escuro.\n\n'
            'Ele carimba o ar. Um selo flamejante "REPROVADO" surge sobre um dos vultos.\n\n'
            'O estudante se desfaz em partículas de código e desaparece.\n\n'
            '${_player.nome} para diante do palco.';
        _mode = 'meetRector';
      });

  void _meetRector() => _set(() {
        _storyText =
            'Magnífico: "Mais um aluno..."\n\n'
            '"Vejo que atravessou o campus, sobreviveu aos laboratórios e coletou as assinaturas."\n\n'
            '"Mas aqui, ${_player.nome}, a lógica é outra. O sistema não aceita erros."';
        _mode = 'dialogueChoice';
      });

  void _present() => _set(() {
        _storyText =
            '${_player.titulo} ${_player.nome}: "Eu não cometi erros. Aqui estão as provas do meu esforço!"\n\n'
            'Magnífico observa os documentos em silêncio.\n\n'
            'Magnífico: "Provas não significam aprovação. Elas apenas confirmam que você chegou até aqui."\n\n'
            'A toga negra do Reitor se expande cobrindo o palco como névoa escura.';
        _mode = 'beforeBattle';
      });

  void _challenge() => _set(() {
        _storyText =
            '${_player.titulo} ${_player.nome}: "O seu sistema é falho, e eu vim aqui para encerrar esse ciclo."\n\n'
            'Os vultos nas poltronas levantam a cabeça pela primeira vez.\n\n'
            'Magnífico: "Rebeldia disfarçada de coragem. Já vi isso antes."';
        _mode = 'beforeBattle';
      });

  void _startBattle() => _set(() {
        _mode = 'battle';
        _storyText =
            'Magnífico bate sua caneta gigante no chão.\n\n'
            '"Se deseja sair deste pesadelo, prove que merece a aprovação final."';
      });

  void _attack() => _set(() {
        final r = _battle.atacarJogador();
        int dano = r.dano;
        if (_player.skills.contains('Clean Code') && r.tipo != TipoAtaque.miss) dano += 10;
        _bossHp = (_bossHp - dano).clamp(0, _bossHpMax);
        _storyText = '${r.mensagem}${_player.skills.contains('Clean Code') && r.tipo != TipoAtaque.miss ? " (+10 Clean Code!)" : ""}';
        if (_bossHp <= 0) {
          _mode = 'ending';
          _storyText = '${_player.nome} desfere o golpe final.\n\nMagnífico: "Impossível... o ciclo não deveria ser quebrado..."';
          return;
        }
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}\nSua vida: ${_player.hp}/${_player.hpMax}';
        if (_player.hp <= 0) _mode = 'lose';
      });

  void _useSkill() => _set(() {
        if (_player.skills.isEmpty) { _storyText = 'Nenhuma skill disponível.'; return; }
        int dano = 0; String used = '';
        if (_player.skills.contains('Clean Code')) { dano = 50; used = 'Clean Code'; }
        else if (_player.skills.contains('Raciocínio Lógico')) { dano = 40; used = 'Raciocínio Lógico'; }
        else if (_player.skills.contains('Argumentação Final')) { dano = 35; used = 'Argumentação Final'; }
        else { dano = 25; used = _player.skills.first; }
        _bossHp = (_bossHp - dano).clamp(0, _bossHpMax);
        _storyText = '${_player.nome} usou $used! $dano de dano!';
        if (_bossHp <= 0) {
          _mode = 'ending';
          _storyText += '\n\nMagnífico: "Então... você realmente concluiu a jornada."';
          return;
        }
        _battle.incrementarTurno();
        final c = _battle.atacarChefe(_bossAtaque);
        _player = _player.copyWith(hp: (_player.hp - c.dano).clamp(0, _player.hpMax));
        _storyText += '\n\n${c.mensagem}';
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

  void _receiveFinalReward() {
    if (_finalRewardReceived) return;
    final inv = List<String>.from(_player.inventario)..add('Diploma');
    final sk = List<String>.from(_player.skills)..add('Resiliência Acadêmica');
    final novasFases = _player.fasesVencidas + 1;
    _player = _player.copyWith(
      inventario: inv, skills: sk, fasesVencidas: novasFases, hp: _player.hpMax + 20);
    _set(() {
      _finalRewardReceived = true;
      _storyText =
          '🎓 PARABÉNS, ${_player.nome.toUpperCase()}!\n\n'
          'Você concluiu a jornada acadêmica!\n\n'
          '🎁 Item: Diploma\n✨ Skill: Resiliência Acadêmica\n'
          '⚔️ Bônus ATK final: +${_player.bonusAtaque}\n'
          '❤️ HP máximo final: ${_player.hpMax}\n\n'
          '"Seu esforço foi... notável. O diploma é seu." — Magnífico';
    });
  }

  void _lose() => _set(() {
        _player = _player.copyWith(hp: _player.hpMax);
        _bossHp = _bossHpMax; _mode = 'intro';
        _battle = BattleHelper(bonusAtaque: _player.bonusAtaque);
        _storyText = 'REPROVADO. O ciclo continua.\n\nVocê acorda novamente na entrada do Auditório.';
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Auditório — Palco da Aprovação',
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
            StatusCard(player: _player, bossLabel: 'Magnífico',
                bossHp: _bossHp, bossHpMax: _bossHpMax,
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
                      Center(

                        child: SizedBox(

                          height: 170,

                          child: ClipRRect(

                            borderRadius: BorderRadius.circular(10),

                            child: Image.asset(

                              'assets/backgrounds/auditorio.png',

                              fit: BoxFit.contain,

                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),

                            ),

                          ),

                        ),

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
        if (_mode != 'battle')
          Positioned(
            bottom: 120,
            right: 14,
            child: MiniMapa(ambienteAlvo: 'auditorio'),
          ),
      ]),
    );
  }

  Widget _buildActions() {
    if (_mode == 'intro') return _btn('Entrar no Auditório', Icons.theater_comedy, _startCutscene);
    if (_mode == 'cutsceneTwo') return _btn('Continuar', Icons.arrow_forward, _continueCutscene);
    if (_mode == 'meetRector') return _btn('Observar Magnífico', Icons.visibility, _meetRector);
    if (_mode == 'dialogueChoice') return Column(children: [
      _btn('Apresentar as assinaturas', Icons.assignment, _present),
      _btn('Desafiar o sistema', Icons.gavel, _challenge),
    ]);
    if (_mode == 'beforeBattle') return _btn('Iniciar batalha final', Icons.sports_martial_arts, _startBattle);
    if (_mode == 'battle') return Column(children: [
      BattleActions(player: _player, battle: _battle,
          onAtacar: _attack, onUsarItem: _usarItem,
          onFugir: () => Navigator.pop(context)),
      if (_player.skills.isNotEmpty)
        Padding(padding: const EdgeInsets.only(top: 6),
          child: _btn('Usar skill (${_player.skills.last})', Icons.bolt, _useSkill)),
    ]);
    if (_mode == 'ending') return Column(children: [
      _btn(_finalRewardReceived ? 'Diploma recebido 🎓' : 'Receber Diploma',
          Icons.school, _finalRewardReceived ? () {} : _receiveFinalReward),
      if (_finalRewardReceived)
        _btn('Voltar ao início', Icons.home, () =>
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false)),
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
