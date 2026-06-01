import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/player_storage.dart';
import '../widgets/mini_mapa.dart';
import 'continue_screen.dart';

class RefeitorioScreen extends StatefulWidget {
  final Player player;
  final bool voltouDeH15;
  const RefeitorioScreen({super.key, required this.player, this.voltouDeH15 = false});
  @override
  State<RefeitorioScreen> createState() => _RefeitorioScreenState();
}

class _RefeitorioScreenState extends State<RefeitorioScreen> {
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
        '${_player.nome} chega ao Refeitório da PUC-Campinas.\n\n'
        'O ambiente é movimentado. O cheiro de café e almoço domina o espaço.\n\n'
        'Pela primeira vez desde o H15, ${_player.nome} sente que encontrou um lugar seguro.';
  }

  void _set(VoidCallback fn) => setState(fn);

  void _explore() => _set(() {
        _storyText =
            '${_player.nome} observa melhor o Refeitório.\n\n'
            'Ao fundo, Nutri prepara cafés atrás do balcão. '
            'Próximo a uma mesa, um Veterano mexe em uma mochila cheia de cabos e livros.';
        _mode = 'mainChoice';
      });

  void _talkNutri() => _set(() {
        _storyText =
            'Nutri: "${_player.titulo} ${_player.nome}, você parece exausto. Aqui é uma Zona Segura.\n\n'
            'Posso restaurar seu HP gratuitamente ou vender um Café Energético por 20 créditos."';
        _mode = 'nutriChoice';
      });

  void _heal() => _set(() {
        _player = _player.copyWith(hp: _player.hpMax);
        PlayerStorage.salvar(_player);
        _storyText =
            '${_player.nome} recupera completamente sua vida.\n\n'
            'HP: ${_player.hp}/${_player.hpMax}\n\n'
            'Nutri: "Pronto. Agora tente não desperdiçar isso."';
      });

  void _buyCoffee() => _set(() {
        if (_cafeComprado) { _storyText = 'Nutri: "Você já comprou um Café Energético aqui."'; return; }
        if (_player.dinheiro < 20) { _storyText = 'Nutri: "Sem créditos, sem café."'; return; }
        _cafeComprado = true;
        final inv = List<String>.from(_player.inventario)..add('Café Energético');
        _player = _player.copyWith(inventario: inv, dinheiro: _player.dinheiro - 20);
        PlayerStorage.salvar(_player);
        _storyText = '${_player.nome} comprou um Café Energético.\nDinheiro restante: ${_player.dinheiro} créditos.';
      });

  void _talkVeterano() => _set(() {
        _storyText =
            'Veterano: "${_player.nome}, se você quer sobreviver ao campus, não basta estudar. '
            'Tem que saber a hora certa de parar, recuperar energia e voltar mais forte."';
        _mode = 'veteranoChoice';
      });

  void _prepare() => _set(() {
        _preparoConcluido = true;
        final sk = List<String>.from(_player.skills);
        if (!sk.contains('Gestão de Tempo')) sk.add('Gestão de Tempo');
        final inv = List<String>.from(_player.inventario);
        if (!_cafeComprado && !inv.contains('Café Energético')) {
          inv.add('Café Energético'); _cafeComprado = true;
        }
        _player = _player.copyWith(skills: sk, inventario: inv);
        PlayerStorage.salvar(_player);
        _storyText = 'Veterano: "Boa escolha."\n\nSkill: Gestão de Tempo\nItem: Café Energético';
        _mode = 'readyToLeave';
      });

  void _leaveWithout() => _set(() {
        _storyText = 'Veterano: "Coragem é útil. Teimosia também parece coragem até dar errado."';
        _mode = 'readyToLeave';
      });

  void _goNext() {
    PlayerStorage.salvar(_player);
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ContinueScreen(player: _player),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Refeitório — Zona Segura',
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
            Card(
              color: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Text('STATUS DE ${_player.nome.toUpperCase()}',
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
                                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
    if (_mode == 'intro') return _btn('Explorar Refeitório', Icons.restaurant, _explore);
    if (_mode == 'mainChoice') return Column(children: [
      _btn('Conversar com Nutri', Icons.local_cafe, _talkNutri),
      _btn('Conversar com Veterano', Icons.backpack, _talkVeterano),
    ]);
    if (_mode == 'nutriChoice') return Column(children: [
      _btn('Restaurar HP', Icons.healing, _heal),
      _btn('Comprar Café Energético (20cr)', Icons.local_cafe, _buyCoffee),
      _btn('Voltar', Icons.arrow_back, _explore),
    ]);
    if (_mode == 'veteranoChoice') return Column(children: [
      _btn('Quero me preparar antes de seguir', Icons.access_time, _prepare),
      _btn('Vou seguir sem perder tempo', Icons.directions_run, _leaveWithout),
    ]);
    if (_mode == 'readyToLeave') return Column(children: [
      _btn(widget.voltouDeH15 ? 'Ir para a Politécnica' : 'Ir para o H06',
          Icons.arrow_forward, _goNext),
      _btn('Voltar ao Refeitório', Icons.restaurant, _explore),
    ]);
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