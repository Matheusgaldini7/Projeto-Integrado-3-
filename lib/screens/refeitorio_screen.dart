import 'package:flutter/material.dart';
import '../models/player.dart';
import 'home_screen.dart';
import '../widgets/mini_mapa.dart';
import '../widgets/app_button.dart';
import '../services/jogador_service.dart';

class RefeitorioScreen extends StatefulWidget {
  final Player player;
  final bool voltouDeH15;
  const RefeitorioScreen({super.key, required this.player, this.voltouDeH15 = false});
  @override
  State<RefeitorioScreen> createState() => _RefeitorioScreenState();
}

class _RefeitorioScreenState extends State<RefeitorioScreen> {
  final _jogadorService = JogadorService();
  late Player _player;
  String _mode = 'intro';
  bool _cafeComprado = false;
  bool _preparoConcluido = false;
  late String _storyText;

  @override
  void initState() {
    super.initState();
    _player = widget.player;
    _storyText =
        '${_player.nickname} chega ao Refeitório da PUC-Campinas.\n\n'
        'O ambiente é movimentado. O cheiro de café e almoço domina o espaço.\n\n'
        '${_player.nickname} sente que encontrou um lugar seguro.';
  }

  void _set(VoidCallback fn) => setState(fn);

  void _explore() => _set(() {
        _storyText =
            '${_player.nickname} observa melhor o Refeitório.\n\n'
            'Ao fundo, Nutri prepara cafés atrás do balcão. '
            'Próximo a uma mesa, um Veterano mexe em uma mochila cheia de cabos e livros.';
        _mode = 'mainChoice';
      });

  void _talkNutri() => _set(() {
        _storyText =
            'Nutri: "${_player.titulo} ${_player.nickname}, você parece exausto. Aqui é uma Zona Segura.\n\n'
            'Posso restaurar seu HP gratuitamente ou vender um Café Energético por 20 créditos."';
        _mode = 'nutriChoice';
      });

  Future<void> _heal() async {
    
    bool estavaMorto = _player.hp <= 0;

    final playerAtualizado = _player.copyWith(hp: _player.hpMax);
    await _jogadorService.salvarJogador(playerAtualizado);

    if (estavaMorto) {
      _set(() {
      _player = playerAtualizado;
      _storyText =
          '${_player.nickname} recupera completamente sua vida.\n\n'
          'HP: ${_player.hp}/${_player.hpMax}\n\n'
          'Nutri: "Pronto. Agora tente não morrer de novo."';
    });
    } else {
      _set(() {
        _player = playerAtualizado;
        _storyText =
            '${_player.nickname} recupera completamente sua vida.\n\n'
            'HP: ${_player.hp}/${_player.hpMax}\n\n'
            'Nutri: "Pronto. Agora tente não desperdiçar isso."';
      });
    }
  }
  Future<void> _buyCoffee() async {
    if (_cafeComprado) { _set(() => _storyText = 'Nutri: "Você já comprou um Café Energético aqui."'); return; }
    if (_player.dinheiro < 20) { _set(() => _storyText = 'Nutri: "Sem créditos, sem café."'); return; }
    
    final inv = List<String>.from(_player.inventario)..add('Café Energético');
    final playerAtualizado = _player.copyWith(
      inventario: inv, 
      dinheiro: _player.dinheiro - 20
    );
    await _jogadorService.salvarJogador(playerAtualizado);
    
    _set(() {
      _cafeComprado = true;
      _player = playerAtualizado;
      _storyText = '${_player.nickname} comprou um Café Energético.\nDinheiro restante: ${_player.dinheiro} créditos.';
    });
  }

  void _talkVeterano() => _set(() {
        _storyText =
            'Veterano: "${_player.nickname}, se você quer sobreviver ao campus, não basta estudar. '
            'Tem que saber a hora certa de parar, recuperar energia e voltar mais forte."';
        _mode = 'veteranoChoice';
      });

  void _prepare() async {
    _preparoConcluido = true;
    final sk = List<String>.from(_player.skills);
    if (!sk.contains('Gestão de Tempo')) sk.add('Gestão de Tempo');
    final inv = List<String>.from(_player.inventario);
    if (!_cafeComprado && !inv.contains('Café Energético')) {
      inv.add('Café Energético'); _cafeComprado = true;
    }
    _player = _player.copyWith(skills: sk, inventario: inv);
    await _jogadorService.salvarJogador(_player);
    _set(() {
      _storyText = 'Veterano: "Boa escolha."\n\nSkill: Gestão de Tempo\nItem: Café Energético';
      _mode = 'readyToLeave';
      _preparoConcluido = true;
    });
  }

  void _leaveWithout() => _set(() {
        _storyText = 'Veterano: "Coragem é útil. Teimosia também parece coragem até dar errado."';
        _mode = 'readyToLeave';
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            (_mode == 'intro' || _mode == 'mainChoice') 
                ? Icons.home 
                : Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (_mode == 'intro' || _mode == 'mainChoice') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            } else {
              if (_mode == 'readyToLeave') {
                Navigator.pop(context);
              } else {
                _set(() => _mode = 'mainChoice');
              }
            }
          },
        ),
        title: const Text('Refeitório — Zona Segura', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Card(
              color: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text('STATUS DE ${_player.nickname.toUpperCase()}',
                      style: const TextStyle(color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const Divider(color: Color(0xFFF59E0B)),
                  _hpBar('❤️ Vida', _player.hp, _player.hpMax),
                  const SizedBox(height: 4),
                  Text('💰 ${_player.dinheiro} créditos  ·  🎒 ${_player.inventario.join(", ")}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12)),
                  if (_preparoConcluido)
                    const Text('☕ Preparação ativa',
                        style: TextStyle(color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
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
                          style: const TextStyle(fontSize: 16,
                              height: 1.5, color: Color(0xFFE5E7EB))),
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
                                      'assets/backgrounds/refeitorio.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: MiniMapa(ambienteAlvo: widget.voltouDeH15 ? 'politecnica' : 'h06'),
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

  Widget _hpBar(String label, int hp, int max) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: $hp/$max',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (hp / max).clamp(0.0, 1.0), minHeight: 10,
            backgroundColor: const Color(0xFF374151),
            valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
          ),
        ),
      ]);

  Widget _buildActions() {
      if (_mode == 'intro') {
        return AppButton(
          label: 'Explorar Refeitório', 
          icon: Icons.restaurant, 
          onPressed: _explore
        );
      }
      if (_mode == 'mainChoice') {
        return Column(children: [
          AppButton(label: 'Conversar com Nutri', icon: Icons.local_cafe, onPressed: _talkNutri),
          AppButton(label: 'Conversar com Veterano', icon: Icons.backpack, onPressed: _talkVeterano),
          AppButton(label: 'Voltar à exploração', icon: Icons.map, onPressed: () => Navigator.pop(context)),
        ]);
      }
      if (_mode == 'nutriChoice') {
        return Column(children: [
          AppButton(label: 'Restaurar HP', icon: Icons.healing, onPressed: _heal),
          AppButton(label: 'Comprar Café Energético (20cr)', icon: Icons.local_cafe, onPressed: _buyCoffee),
        ]);
      }
      if (_mode == 'veteranoChoice') {
        bool jaPossuiSkill = _player.skills.contains('Gestão de Tempo');
        return Column(children: [
          if (!_preparoConcluido && !jaPossuiSkill)
            AppButton(label: 'Quero me preparar antes de seguir', icon: Icons.access_time, onPressed: _prepare),
          
          AppButton(label: 'Vou seguir sem perder tempo', icon: Icons.directions_run, onPressed: _leaveWithout),
        ]);
      }
      if (_mode == 'readyToLeave') {
      return AppButton(label: 'Voltar à exploração', icon: Icons.map, onPressed: () => Navigator.pop(context));
    }
      return const SizedBox.shrink();
    }
}
