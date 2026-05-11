import 'dart:math';
import 'package:flutter/material.dart';


class AuditorioScreen extends StatefulWidget {
  final String playerName;
  final String playerGender;

  const AuditorioScreen({
    super.key,
    required this.playerName,
    required this.playerGender,
  });

  @override
  State<AuditorioScreen> createState() => _AuditorioScreenState();
}

class _AuditorioScreenState extends State<AuditorioScreen> {
  int playerHp = 120;
  int maxHp = 120;
  int bossHp = 220;
  int dinheiro = 100;

  bool bossDefeated = false;
  bool finalRewardReceived = false;

  List<String> inventory = ['Cura', 'Café Energético', 'IDE'];
  List<String> skills = [
    'Argumentação Final',
    'Raciocínio Lógico',
    'Gestão de Tempo',
    'Clean Code',
  ];

  String mode = 'intro';

  String get playerTitle {
    return widget.playerGender == 'feminino' ? 'Aluna' : 'Aluno';
  }

  late String storyText;

  @override
  void initState() {
    super.initState();

    storyText =
        '${widget.playerName} chega ao Grande Auditório - Palco da Aprovação.\n\n'
        'O ambiente é vasto e escuro. O único ponto de luz é um holofote central focado no palco.\n\n'
        'As poltronas estão ocupadas por vultos sombrios de estudantes reprovados. O ar parece pesado, como se a própria burocracia acadêmica tivesse tomado forma.';
  }

  void startCutscene() {
    setState(() {
      storyText =
          'A câmera acompanha ${widget.playerName} caminhando pelo corredor central do Auditório.\n\n'
          'Cada passo ecoa no silêncio. A penumbra azulada cobre o ambiente, enquanto partículas de poeira flutuam nos feixes de luz dos projetores.\n\n'
          'Nas fileiras laterais, vultos cinzentos permanecem de cabeça baixa. Um por um, eles se levantam e caminham até o palco.\n\n'
          'No centro, atrás de uma mesa monumental feita de pilhas de papéis, está o Reitor das Sombras: Magnífico.';
      mode = 'cutsceneTwo';
    });
  }

  void continueCutscene() {
    setState(() {
      storyText =
          'Magnífico levanta uma caneta que brilha em vermelho escuro.\n\n'
          'Ele carimba o ar. Um selo flamejante escrito "REPROVADO" surge sobre um dos vultos.\n\n'
          'O estudante se desfaz em partículas de código e desaparece.\n\n'
          'O som ambiente mistura batidas de coração com o tique-taque acelerado de um relógio invisível.\n\n'
          '${widget.playerName} para diante do palco.';
      mode = 'meetRector';
    });
  }

  void meetRector() {
    setState(() {
      storyText =
          'O Reitor interrompe o julgamento dos vultos e ajusta os óculos, que brilham com uma luz branca e fria.\n\n'
          'Magnífico: "Mais um aluno..."\n\n'
          'Magnífico: "Vejo que atravessou o campus, sobreviveu aos laboratórios e coletou as assinaturas."\n\n'
          'Magnífico: "Mas aqui, ${widget.playerName}, a lógica é outra. O sistema não aceita erros."';
      mode = 'dialogueChoice';
    });
  }

  void presentSignatures() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "Eu não cometi erros. Aqui estão as provas do meu esforço!"\n\n'
          '${widget.playerName} apresenta os boletins e assinaturas conquistados durante a jornada.\n\n'
          'Magnífico observa os documentos em silêncio.\n\n'
          'Magnífico: "Provas não significam aprovação. Elas apenas confirmam que você chegou até aqui."\n\n'
          'A toga negra do Reitor se expande, cobrindo o fundo do palco como uma névoa escura.';
      mode = 'beforeBattle';
    });
  }

  void challengeRector() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "O seu sistema é falho, e eu vim aqui para encerrar esse ciclo."\n\n'
          'Os vultos nas poltronas levantam a cabeça pela primeira vez.\n\n'
          'Magnífico sorri de forma fria.\n\n'
          'Magnífico: "Rebeldia disfarçada de coragem. Já vi isso antes."\n\n'
          'A toga negra do Reitor se expande, cobrindo o fundo do palco como uma névoa escura.';
      mode = 'beforeBattle';
    });
  }

  void startFinalBattle() {
    setState(() {
      mode = 'battle';

      storyText =
          'Magnífico bate sua caneta gigante no chão.\n\n'
          'A interface de batalha surge com uma falha digital. Barras de vida, itens e habilidades aparecem diante de ${widget.playerName}.\n\n'
          'Magnífico: "Muito bem. Se deseja sair deste pesadelo, prove que merece a aprovação final."';
    });
  }

  void playerAttack() {
    setState(() {
      int damage = 25;

      if (skills.contains('Clean Code')) {
        damage += 10;
      }

      bossHp -= damage;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'ending';

        storyText =
            '${widget.playerName} desfere o golpe final contra Magnífico.\n\n'
            'A caneta gigante cai no chão e se parte ao meio. O selo de reprovação desaparece do ar.\n\n'
            'Os vultos nas cadeiras começam a se desfazer em luz.\n\n'
            'Magnífico: "Impossível... o ciclo não deveria ser quebrado..."';
        return;
      }

      rectorTurn();
    });
  }

  void useSkill() {
    setState(() {
      if (skills.isEmpty) {
        storyText =
            '${widget.playerName} tentou usar uma habilidade, mas nenhuma skill está disponível.\n\n'
            'Magnífico: "Sem preparo. Sem mérito."';
        return;
      }

      int damage = 0;
      String skillUsed = '';

      if (skills.contains('Clean Code')) {
        damage = 50;
        skillUsed = 'Clean Code';
      } else if (skills.contains('Raciocínio Lógico')) {
        damage = 40;
        skillUsed = 'Raciocínio Lógico';
      } else if (skills.contains('Argumentação Final')) {
        damage = 35;
        skillUsed = 'Argumentação Final';
      } else {
        damage = 25;
        skillUsed = skills.first;
      }

      bossHp -= damage;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'ending';

        storyText =
            '${widget.playerName} usa $skillUsed e rompe a defesa final de Magnífico.\n\n'
            'O palco treme. A mesa de papéis desmorona, e as assinaturas conquistadas brilham ao redor de ${widget.playerName}.\n\n'
            'Magnífico: "Então... você realmente concluiu a jornada."';
        return;
      }

      storyText =
          '${widget.playerName} usou $skillUsed.\n\n'
          'Dano causado: $damage\n'
          'Vida de Magnífico: $bossHp/220';

      rectorTurn();
    });
  }

  void useItem() {
    setState(() {
      if (inventory.contains('Cura')) {
        inventory.remove('Cura');
        playerHp += 35;

        if (playerHp > maxHp) {
          playerHp = maxHp;
        }

        storyText =
            '${widget.playerName} usou uma Cura.\n\n'
            'Vida restaurada em 35 pontos.\n'
            'Vida atual: $playerHp/$maxHp';
        return;
      }

      if (inventory.contains('Café Energético')) {
        inventory.remove('Café Energético');
        playerHp += 25;

        if (playerHp > maxHp) {
          playerHp = maxHp;
        }

        storyText =
            '${widget.playerName} usou Café Energético.\n\n'
            'O foco retorna em meio à pressão do Auditório.\n'
            'Vida atual: $playerHp/$maxHp';
        return;
      }

      storyText =
          '${widget.playerName} tentou usar um item, mas o inventário está vazio.\n\n'
          'Magnífico: "Sem recursos. Sem justificativas."';
    });
  }

  void rectorTurn() {
    final random = Random();

    final bool rectorMissed = random.nextInt(100) < 35;

    if (rectorMissed) {
      storyText +=
          '\n\nMagnífico tenta carimbar ${widget.playerName} com o selo de REPROVADO, mas erra.\n\n'
          'Vida de ${widget.playerName}: $playerHp/$maxHp\n'
          'Vida de Magnífico: $bossHp/220';
      return;
    }

    int damage = 30;

    if (skills.contains('Gestão de Tempo')) {
      damage -= 5;
    }

    playerHp -= damage;

    if (playerHp <= 0) {
      loseFinalBattle();
    } else {
      storyText +=
          '\n\nMagnífico acerta ${widget.playerName} com um carimbo sombrio.\n\n'
          'Dano recebido: $damage\n'
          'Vida de ${widget.playerName}: $playerHp/$maxHp\n'
          'Vida de Magnífico: $bossHp/220';
    }
  }

  void loseFinalBattle() {
    setState(() {
      playerHp = maxHp;
      bossHp = 220;
      bossDefeated = false;
      finalRewardReceived = false;
      mode = 'intro';

      storyText =
          '${widget.playerName} foi derrotado no Auditório.\n\n'
          'O selo "REPROVADO" surge no ar, mas antes de atingir o personagem, tudo se desfaz em ruído.\n\n'
          '${widget.playerName} abre os olhos novamente na entrada do Auditório.\n\n'
          'O julgamento ainda não terminou.';
    });
  }

  void receiveFinalReward() {
    setState(() {
      finalRewardReceived = true;

      storyText =
          'Magnífico abaixa a cabeça.\n\n'
          'Magnífico: "O sistema reconhece sua aprovação."\n\n'
          'As assinaturas conquistadas se unem em um único documento: o Diploma Final.\n\n'
          '${widget.playerName} sente o peso do campus desaparecer.\n\n'
          'Item final obtido: Diploma da Aprovação\n\n'
          'O pesadelo acadêmico começa a se desfazer.';
    });
  }

  void finalCutscene() {
    setState(() {
      mode = 'final';

      storyText =
          '${widget.playerName} acorda no mundo real.\n\n'
          'O auditório sombrio desapareceu. As luzes frias, os vultos e o som dos carimbos não existem mais.\n\n'
          'Sobre a mesa, está o TCC antes recusado. Agora, marcado com a palavra: APROVADO.\n\n'
          '${widget.playerName} respira fundo.\n\n'
          'Depois de atravessar o H15, a Politécnica, o Refeitório, o H06 e o Auditório, a jornada finalmente chega ao fim.';
    });
  }

  void resetFinalArea() {
    setState(() {
      playerHp = maxHp;
      bossHp = 220;
      dinheiro = 100;
      bossDefeated = false;
      finalRewardReceived = false;
      inventory = ['Cura', 'Café Energético', 'IDE'];
      skills = [
        'Argumentação Final',
        'Raciocínio Lógico',
        'Gestão de Tempo',
        'Clean Code',
      ];
      mode = 'intro';

      storyText =
          '${widget.playerName} chega ao Grande Auditório - Palco da Aprovação.\n\n'
          'O ambiente é vasto e escuro. O único ponto de luz é um holofote central focado no palco.\n\n'
          'As poltronas estão ocupadas por vultos sombrios de estudantes reprovados. O ar parece pesado, como se a própria burocracia acadêmica tivesse tomado forma.';
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
            backgroundColor: const Color(0xFF7C2D12),
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

  Widget statusText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Grande Auditório — Palco da Aprovação',
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
              Color(0xFF050505),
              Color(0xFF111827),
              Color(0xFF3B0A0A),
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
                    color: Color(0xFFEF4444),
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
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Divider(color: Color(0xFFEF4444)),
                      hpBar(
                        label: '❤️ Vida',
                        hp: playerHp,
                        maxHp: maxHp,
                        color: Colors.redAccent,
                      ),
                      if (mode == 'battle')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: hpBar(
                            label: '🎓 Magnífico',
                            hp: bossHp,
                            maxHp: 220,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      statusText('💰 Dinheiro: $dinheiro créditos'),
                      statusText(
                        '🎒 Inventário: ${inventory.isEmpty ? "Vazio" : inventory.join(", ")}',
                      ),
                      statusText(
                        '⚡ Skills: ${skills.isEmpty ? "Nenhuma" : skills.join(", ")}',
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
                      color: Color(0xFF7F1D1D),
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
            text: 'Assistir cutscene final',
            icon: Icons.movie,
            onPressed: startCutscene,
          ),
          rpgButton(
            text: 'Reiniciar área',
            icon: Icons.restart_alt,
            onPressed: resetFinalArea,
          ),
        ],
      );
    }

    if (mode == 'cutsceneTwo') {
      return Column(
        children: [
          rpgButton(
            text: 'Continuar cutscene',
            icon: Icons.arrow_forward,
            onPressed: continueCutscene,
          ),
        ],
      );
    }

    if (mode == 'meetRector') {
      return Column(
        children: [
          rpgButton(
            text: 'Encarar Magnífico',
            icon: Icons.visibility,
            onPressed: meetRector,
          ),
        ],
      );
    }

    if (mode == 'dialogueChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Apresentar assinaturas',
            icon: Icons.description,
            onPressed: presentSignatures,
          ),
          rpgButton(
            text: 'Desafiar o Reitor',
            icon: Icons.gavel,
            onPressed: challengeRector,
          ),
        ],
      );
    }

    if (mode == 'beforeBattle') {
      return Column(
        children: [
          rpgButton(
            text: 'Iniciar batalha final',
            icon: Icons.warning,
            onPressed: startFinalBattle,
          ),
        ],
      );
    }

    if (mode == 'battle') {
      return Column(
        children: [
          rpgButton(
            text: 'Atacar',
            icon: Icons.flash_on,
            onPressed: playerAttack,
          ),
          rpgButton(
            text: 'Usar item',
            icon: Icons.healing,
            onPressed: useItem,
          ),
          rpgButton(
            text: 'Usar habilidade',
            icon: Icons.bolt,
            onPressed: useSkill,
          ),
          rpgButton(
            text: 'Fugir indisponível no julgamento final',
            icon: Icons.block,
            onPressed: null,
          ),
        ],
      );
    }

    if (mode == 'ending') {
      return Column(
        children: [
          rpgButton(
            text: finalRewardReceived
                ? 'Diploma recebido'
                : 'Receber Diploma Final',
            icon: Icons.school,
            onPressed: finalRewardReceived ? null : receiveFinalReward,
          ),
          if (finalRewardReceived)
            rpgButton(
              text: 'Ver final',
              icon: Icons.emoji_events,
              onPressed: finalCutscene,
            ),
        ],
      );
    }

    if (mode == 'final') {
      return Column(
        children: [
          rpgButton(
            text: 'Reiniciar jogo final',
            icon: Icons.restart_alt,
            onPressed: resetFinalArea,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}