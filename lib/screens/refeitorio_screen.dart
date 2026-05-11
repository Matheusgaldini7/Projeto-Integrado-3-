import 'package:flutter/material.dart';
import 'h06_screen.dart';

class RefeitorioScreen extends StatefulWidget {
  final String playerName;
  final String playerGender;

  const RefeitorioScreen({
    super.key,
    required this.playerName,
    required this.playerGender,
  });

  @override
  State<RefeitorioScreen> createState() => _RefeitorioScreenState();
}

class _RefeitorioScreenState extends State<RefeitorioScreen> {
  int playerHp = 60;
  int maxHp = 100;
  int dinheiro = 60;

  List<String> inventory = ['Cura'];
  List<String> skills = [];

  bool cafeComprado = false;
  bool preparoConcluido = false;
  bool dicaRecebida = false;

  String mode = 'intro';

  String get playerTitle {
  return widget.playerGender == 'feminino' ? 'Aluna' : 'Aluno';
  } 

  late String storyText;

  @override
  void initState() {
    super.initState();

    storyText =
        '${widget.playerName} chega ao Refeitório da PUC-Campinas.\n\n'
        'O ambiente é movimentado: estudantes conversam, bandejas batem nas mesas, cadeiras arrastam pelo chão e pedidos são chamados ao fundo.\n\n'
        'O cheiro de café, salgado e almoço domina o espaço. Pela primeira vez desde o H15, ${widget.playerName} sente que encontrou um lugar seguro. Ou quase.';
  }
  void exploreRefeitorio() {
    setState(() {
        storyText =
            '${widget.playerName} observa melhor o Refeitório.\n\n'
            'Apesar da movimentação intensa, o local transmite uma sensação de pausa no meio do caos acadêmico.\n\n'
            'Ao fundo, uma figura tranquila prepara cafés atrás do balcão. Próximo a uma mesa, um veterano mexe em uma mochila cheia de cabos, livros e peças antigas.\n\n'
            '${widget.playerName} pode conversar com a Nutri ou com o Veterano.';
      mode = 'mainChoice';
    });
  }

  void talkToNutri() {
    setState(() {
      storyText =
          '${widget.playerName} se aproxima do balcão.\n\n'
          'Nutri: "$playerTitle ${widget.playerName}, você parece exausto. Aqui é uma Zona Segura. Nenhum chefe entra neste espaço."\n\n'
          'Nutri: "Se quiser continuar sua jornada, precisa cuidar da sua energia. Conhecimento sem descanso só vira desespero organizado."\n\n'
          'Nutri: "Posso restaurar seu HP gratuitamente ou vender um Café Energético por 20 créditos."';
            mode = 'nutriChoice';
    });
  }

  void healPlayer() {
    setState(() {
      playerHp = maxHp;

      storyText =
          'Nutri prepara uma refeição rápida e um copo de água para ${widget.playerName}.\n\n'
          '${widget.playerName} recupera completamente sua vida.\n\n'
          'HP atual: $playerHp/$maxHp\n\n'
          'Nutri: "Pronto, ${widget.playerName}. Agora tente não desperdiçar isso em uma decisão ruim, por favor."';
    });
  }

  void buyCoffee() {
    setState(() {
      if (cafeComprado) {
        storyText =
            'Nutri: "${widget.playerName}, você já comprou um Café Energético aqui."\n\n'
            'Nutri: "Café ajuda, mas exagerar também transforma estudante em impressora tremendo."';
        return;
      }
      if (dinheiro < 20) {
        storyText =
            '${widget.playerName} tenta comprar um Café Energético, mas não possui créditos suficientes.\n\n'
            'Nutri: "Sem créditos, sem café, ${widget.playerName}. O capitalismo também chegou ao mundo sombrio, infelizmente."';
        return;
      }

      dinheiro -= 20;
      cafeComprado = true;
      inventory.add('Café Energético');

      storyText =
          '${widget.playerName} comprou um Café Energético.\n\n'
          'Item adicionado ao inventário: Café Energético\n'
          'Efeito: aumenta sua preparação para o próximo desafio.\n\n'
          'Dinheiro restante: $dinheiro créditos.\n\n'
          'Nutri: "Use bem, ${widget.playerName}. O próximo bloco não vai esperar você respirar."';
    });
  }

  void talkToVeterano() {
    setState(() {
      storyText =
          '${widget.playerName} se aproxima do Veterano.\n\n'
          'Ele carrega uma mochila enorme cheia de cabos, livros antigos, anotações e peças de computador.\n\n'
          'Veterano: "${widget.playerName}, se você quer sobreviver ao campus, não basta estudar. Tem que saber a hora certa de parar, recuperar energia e voltar mais forte."\n\n'
          'Veterano: "Você pode se preparar agora ou seguir sem perder tempo. Só não reclame depois se o próximo bloco te esmagar."';
      mode = 'veteranoChoice';
    });
  }

  void prepareBeforeLeaving() {
    setState(() {
      preparoConcluido = true;
      dicaRecebida = true;

      if (!skills.contains('Gestão de Tempo')) {
        skills.add('Gestão de Tempo');
      }

      if (!inventory.contains('Café Energético')) {
        inventory.add('Café Energético');
        cafeComprado = true;
      }

      storyText =
          '${widget.playerName} decide se preparar antes de seguir.\n\n'
          'O Veterano organiza suas anotações, revisa seus itens e aponta possíveis riscos da próxima área.\n\n'
          'Veterano: "Boa escolha, ${widget.playerName}. Pressa é só outro nome para erro cometido com confiança."\n\n'
          'Skill desbloqueada: Gestão de Tempo\n'
          'Item recebido: Café Energético\n\n'
          '${widget.playerName} seguirá para a próxima fase com mais preparo.';
      mode = 'readyToLeave';
    });
  }

  void leaveWithoutPreparation() {
    setState(() {
      preparoConcluido = false;

      storyText =
          '${widget.playerName} decide seguir sem perder tempo.\n\n'
          'Veterano: "${widget.playerName}, coragem é útil. Teimosia também parece coragem até dar errado."\n\n'
          '${widget.playerName} não recebe bônus de preparação e seguirá para a próxima área com menos recursos.';

      mode = 'readyToLeave';
    });
  }

  void goToNextArea() {
    setState(() {
      storyText =
          '${widget.playerName} se prepara para sair do Refeitório.\n\n'
          '${ifTextNextArea()}';

      mode = 'finished';
    });
  }

  String ifTextNextArea() {
    if (preparoConcluido) {
      return 'Graças ao preparo, você sente que está mais organizado para enfrentar os próximos desafios.\n\n'
          'Próxima área: H06.';
    }

    return 'Sem preparo extra, você sente que a próxima área pode ser mais difícil.\n\n'
        'Próxima área: H06.';
  }

  void goToH06() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => H06Screen(
          playerName: widget.playerName,
          playerGender: widget.playerGender,
        ),
      ),
    );
  }

  void resetArea() {
    setState(() {
      playerHp = 60;
      dinheiro = 60;
      inventory = ['Cura'];
      skills = [];
      cafeComprado = false;
      preparoConcluido = false;
      dicaRecebida = false;
      mode = 'intro';

      storyText =
          '${widget.playerName} chega ao Refeitório da PUC-Campinas.\n\n'
          'O ambiente é movimentado: estudantes conversam, bandejas batem nas mesas, cadeiras arrastam pelo chão e pedidos são chamados ao fundo.\n\n'
          'O cheiro de café, salgado e almoço domina o espaço. Pela primeira vez desde o H15, ${widget.playerName} sente que encontrou um lugar seguro. Ou quase.';
    });
  }

  Widget rpgButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_right),
          label: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF374151),
            disabledForegroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
          ),
        ),
      ),
    );
  }

  Widget hpBar({
    required String label,
    required int hp,
    required int maxHp,
    required Color color,
  }) {
    final double value = hp / maxHp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $hp/$maxHp',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: const Color(0xFF374151),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Refeitório — Zona Segura',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
        elevation: 8,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B0F14),
              Color(0xFF1A1F2B),
              Color(0xFF2A1F13),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(
                    color: Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'STATUS DE ${widget.playerName.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Divider(color: Color(0xFFF59E0B)),
                      hpBar(
                        label: '❤️ Vida',
                        hp: playerHp,
                        maxHp: maxHp,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '💰 Dinheiro: $dinheiro créditos',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '🎒 Inventário: ${inventory.isEmpty ? "Vazio" : inventory.join(", ")}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '⚡ Skills: ${skills.isEmpty ? "Nenhuma" : skills.join(", ")}',
                        textAlign: TextAlign.center,
                      ),
                      if (preparoConcluido)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '☕ Preparação ativa',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Card(
                  color: const Color(0xFF111827),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(
                      color: Color(0xFF64748B),
                      width: 1,
                    ),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: SingleChildScrollView(
                      child: Text(
                        storyText,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    if (mode == 'intro') {
      return Column(
        children: [
          rpgButton(
            text: 'Explorar Refeitório',
            icon: Icons.restaurant,
            onPressed: exploreRefeitorio,
          ),
          rpgButton(
            text: 'Reiniciar área',
            icon: Icons.restart_alt,
            onPressed: resetArea,
          ),
        ],
      );
    }

    if (mode == 'mainChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Conversar com Nutri',
            icon: Icons.local_cafe,
            onPressed: talkToNutri,
          ),
          rpgButton(
            text: 'Conversar com Veterano',
            icon: Icons.backpack,
            onPressed: talkToVeterano,
          ),
        ],
      );
    }

    if (mode == 'nutriChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Restaurar HP',
            icon: Icons.healing,
            onPressed: healPlayer,
          ),
          rpgButton(
            text: 'Comprar Café Energético',
            icon: Icons.local_cafe,
            onPressed: buyCoffee,
          ),
          rpgButton(
            text: 'Voltar',
            icon: Icons.arrow_back,
            onPressed: exploreRefeitorio,
          ),
        ],
      );
    }

    if (mode == 'veteranoChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Quero me preparar antes de seguir',
            icon: Icons.access_time,
            onPressed: prepareBeforeLeaving,
          ),
          rpgButton(
            text: 'Vou seguir sem perder tempo',
            icon: Icons.directions_run,
            onPressed: leaveWithoutPreparation,
          ),
        ],
      );
    }

    if (mode == 'readyToLeave') {
      return Column(
        children: [
          rpgButton(
            text: 'Seguir para a próxima área',
            icon: Icons.arrow_forward,
            onPressed: goToNextArea,
          ),
          rpgButton(
            text: 'Voltar ao Refeitório',
            icon: Icons.restaurant,
            onPressed: exploreRefeitorio,
          ),
        ],
      );
    }

    if (mode == 'finished') {
      return Column(
        children: [
          rpgButton(
            text: 'Ir para H06',
            icon: Icons.computer,
            onPressed: goToH06,
          ),
          rpgButton(
            text: 'Reiniciar área',
            icon: Icons.restart_alt,
            onPressed: resetArea,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}