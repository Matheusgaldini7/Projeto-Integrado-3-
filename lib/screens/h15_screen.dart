import 'dart:math';
import 'package:flutter/material.dart';
import 'politecnica_screen.dart';

class H15Screen extends StatefulWidget {
  final String playerName;
  final String playerGender;

  const H15Screen({
    super.key,
    required this.playerName,
    required this.playerGender,
  });

  @override
  State<H15Screen> createState() => _H15ScreenState();
}

class _H15ScreenState extends State<H15Screen> {
  String get playerTitle {
  return widget.playerGender == 'feminino' ? 'Aluna' : 'Aluno';
  }

  int playerHp = 100;
  int dinheiro = 20;
  int bossHp = 120;

  String storyText =
      'Você acorda desnorteado em um banco próximo ao Bloco H15.\n\n'
      'O campus está vazio, escuro e silencioso. As luzes piscam ao longe.\n\n'
      'À sua frente, uma figura encapuzada observa em silêncio.';

  bool bossDefeated = false;
  bool rewardReceived = false;

  int explorationStep = 0;

  List<String> inventory = ['Cura'];

  List<String> skills = [];

  int currentQuestion = 0;
  int correctAnswers = 0;
  int bossDebuffTurns = 0;

  String mode = 'npcIntro';

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'O que é um sistema de informação?',
      'options': [
        'Um conjunto de pessoas, processos e tecnologia para tratar informações',
        'Apenas um computador ligado à internet',
        'Um jogo instalado no celular',
      ],
      'answer': 0,
    },
    {
      'question': 'Qual destes é um exemplo de dado?',
      'options': [
        'Uma informação analisada',
        'O número 25 registrado em uma tabela',
        'Uma decisão tomada por um gerente',
      ],
      'answer': 1,
    },
    {
      'question': 'Para que serve um banco de dados?',
      'options': [
        'Guardar, organizar e consultar informações',
        'Melhorar o sinal do Wi-Fi',
        'Aumentar o brilho da tela',
      ],
      'answer': 0,
    },
    {
      'question': 'O que é programação?',
      'options': [
        'Criar instruções para o computador executar tarefas',
        'Montar fisicamente um computador',
        'Apenas usar aplicativos prontos',
      ],
      'answer': 0,
    },
    {
      'question': 'Qual é uma função da tecnologia da informação nas empresas?',
      'options': [
        'Apoiar processos, decisões e organização de dados',
        'Substituir totalmente todas as pessoas',
        'Servir apenas para entretenimento',
      ],
      'answer': 0,
    },
  ];

  void goToPolitecnica() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PolitecnicaScreen(
          playerName: widget.playerName,
          playerGender: widget.playerGender,
        ),
      ),
    );
  }

  void askNpcName() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "Qual o seu nome?"\n\n'
          'NPC: "Meu nome não pode ser dito aqui."\n\n'
          'NPC: "Alguns nomes chamam atenção demais neste lugar. Por enquanto, apenas me chame de Guardião do Banco."';
    });
  }

  void askNpcObjective() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "Qual o meu objetivo aqui?"\n\n'
          'Guardião do Banco: "Você precisa derrotar os chefes espalhados pelo campus e coletar os boletins."\n\n'
          'Guardião do Banco: "Cada boletim representa uma etapa da sua aprovação. Sem eles, você nunca chegará ao fim da jornada."\n\n'
          'Guardião do Banco: "O primeiro obstáculo está no H15: Maligno."';
    });
  }

  void askNpcLocation() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "Onde eu estou"\n\n'
          'Guardião do Banco: "Você está na PUC-Campinas... mas não exatamente na mesma que conhecia."\n\n'
          'Guardião do Banco: "Este campus reflete seus desafios acadêmicos. Tudo aqui testa sua lógica, sua resistência e sua vontade de concluir o curso."';
    });
  }

  void continueAfterNpc() {
    setState(() {
      mode = 'explore';
      storyText =
          'Guardião do Banco: "Comece pelo H15."\n\n'
          'Guardião do Banco: "O Maligno. Ele decidirá se você tem base suficiente para continuar."\n\n'
          'O caminho até o bloco parece vazio. Mesmo assim, você sente que algo observa seus passos.';
    });
  }

  void exploreH15() {
    setState(() {
      explorationStep++;

      if (explorationStep == 1) {
        storyText =
            'Você entra em uma sala aleatória do H15.\n\n'
            'As cadeiras estão fora do lugar, o projetor está ligado, mas não há ninguém ali. '
            'Na parede, uma apresentação congelada mostra apenas a frase: "Avaliação pendente".\n\n'
            'Você procura por alguém, mas encontra apenas silêncio.';
      } else if (explorationStep == 2) {
        storyText =
            'Você continua explorando o corredor.\n\n'
            'Mais à frente, vê uma lixeira caída no chão. Papéis estão espalhados, alguns com anotações de provas, códigos incompletos e nomes riscados.\n\n'
            'No meio dos papéis, há uma frase escrita à mão:\n'
            '"O subsolo guarda aquilo que foi recusado."';
      } else if (explorationStep == 3) {
        storyText =
            'Você desce até o subsolo do H15.\n\n'
            'O laboratório está completamente vazio. Os computadores estão ligados, mas nenhuma pessoa aparece nas salas.\n\n'
            'De repente, um barulho metálico ecoa no fundo do corredor.\n\n'
            'Algo ou alguém está ali.';
        mode = 'noiseChoice';
      }
    });
  }

  void hideFromNoise() {
    setState(() {
      storyText =
          'Você tenta se esconder atrás de uma mesa do laboratório.\n\n'
          'Por alguns segundos, o silêncio volta. Então, passos lentos se aproximam.\n\n'
          'Maligno: "Achou mesmo que poderia se esconder dentro da minha própria avaliação?"\n\n'
          'Maligno: "Já que tentou fugir do problema, agora será obrigado a enfrentá-lo."';
      mode = 'battle';
    });
  }

  void followNoise() {
    setState(() {
      storyText =
          'Você decide ir atrás do barulho.\n\n'
          'Ao atravessar o laboratório, encontra Maligno parado diante de um computador com a tela corrompida.\n\n'
          'Maligno: "Então você me encontrou."\n\n'
          'Maligno: "Imagino que queira algo de mim... talvez o boletim que precisa para continuar."\n\n'
          'Maligno: "Você chegou até aqui... mas ainda há uma escolha a ser feita. Como pretende ser avaliado?"';
      mode = 'choice';
    });
  }

  void startQuiz() {
    setState(() {
      currentQuestion = 0;
      correctAnswers = 0;
      mode = 'quiz';
      storyText =
          'Você escolheu responder às perguntas do Maligno.\n\n'
          'Acerte todas para receber o boletim sem lutar.';
    });
  }

  void startBattle() {
    setState(() {
      mode = 'battle';
      storyText =
          'Você escolheu enfrentar o Maligno em uma batalha por turnos.\n\n'
          'Maligno: "Interessante... vamos ver se você aguenta até o final."';
    });
  }

  void answerQuestion(int selectedIndex) {
    final question = questions[currentQuestion];

    setState(() {
      if (selectedIndex == question['answer']) {
        correctAnswers++;
      }

      currentQuestion++;

      if (currentQuestion >= questions.length) {
        if (correctAnswers == questions.length) {
          bossDefeated = true;
          mode = 'reward';
          storyText =
              'Você acertou todas as perguntas!\n\n'
              'Maligno reconhece seu conhecimento e entrega o boletim sem lutar.';
        } else {
          mode = 'battle';
          storyText =
              'Você errou pelo menos uma pergunta.\n\n'
              'Maligno: "Resposta insuficiente. Não importa o caminho... o resultado será o mesmo: você será testado."';
        }
      }
    });
  }

  void playerAttack() {
    setState(() {
      bossHp -= 25;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'reward';
        storyText =
            'Você derrotou Maligno!\n\n'
            'Ele entrega o Boletim do H15, marcado com sua autêntica assinatura.';
        return;
      }

      bossTurn();
    });
  }

  void useSkill() {
    setState(() {
      if (skills.isEmpty) {
        storyText =
            'Você ainda não possui nenhuma habilidade.\n\n'
            'Infelizmente, motivação acadêmica não conta como skill.';
        return;
      }

      bossDebuffTurns = 2;

      storyText =
          'Você usou Argumentação Final!\n\n'
          'Seu discurso enfraqueceu o Maligno.\n'
          'O dano dele será reduzido pelos próximos 2 turnos.';

      bossTurn();
    });
  }

  void useHeal() {
    setState(() {
      if (inventory.contains('Cura')) {
        inventory.remove('Cura');
        playerHp += 30;

        if (playerHp > 100) {
          playerHp = 100;
        }

        storyText =
            'Você usou uma Cura.\n\n'
            'Sua vida foi restaurada em 30 pontos.\n'
            'Vida atual: $playerHp';
      } else {
        storyText =
            'Você tentou usar uma Cura, mas não possui nenhuma.\n\n'
            'Seu inventário está tão vazio quanto o H15.';
      }
    });
  }

  void bossTurn() {
    final random = Random();
    final bool bossMissed = random.nextInt(100) < 65;

    if (bossMissed) {
      storyText =
          'Maligno tentou atacar, mas errou.\n\n'
          'Parece que nem toda avaliação é precisa.\n\n'
          'Sua vida: $playerHp\n'
          'Vida do Maligno: $bossHp';
      return;
    }

    int bossDamage = 20;

    if (bossDebuffTurns > 0) {
      bossDamage = 10;
      bossDebuffTurns--;
    }

    playerHp -= bossDamage;

    if (playerHp <= 0) {
      loseGame();
    } else {
      storyText =
          'Maligno acertou um ataque.\n\n'
          'Dano recebido: $bossDamage\n'
          'Sua vida: $playerHp\n'
          'Vida do Maligno: $bossHp';

      if (bossDebuffTurns > 0) {
        storyText +=
            '\n\nArgumentação Final ainda está ativa por $bossDebuffTurns turno(s).';
      }
    }
  }

  void loseGame() {
    playerHp = 100;
    bossHp = 120;
    bossDefeated = false;
    rewardReceived = false;
    explorationStep = 0;
    bossDebuffTurns = 0;
    inventory = ['Cura', 'Cura'];
    skills = [];
    currentQuestion = 0;
    correctAnswers = 0;
    mode = 'npcIntro';

    storyText =
        'Você perdeu.\n\n'
        'De repente, você abre os olhos e se encontra no H15.\n\n'
        'Você não sabe se o que aconteceu foi apenas um sonho ou se algo realmente aconteceu.\n\n'
        'A figura encapuzada continua ali, observando em silêncio.';
  }

  void receiveReward() {
    setState(() {
      if (!rewardReceived) {
        inventory.add('Caneta da Aprovação');
        skills.add('Argumentação Final');
        rewardReceived = true;
      }

      storyText =
          'Recompensa recebida!\n\n'
          'Boletim obtido: Boletim do H15\n'
          'Marca: Assinatura Autêntica\n\n'
          'Item desbloqueado: CANETA DA APROVAÇÃO\n'
          'Efeito: poderá eliminar uma alternativa incorreta ou aumentar o dano em desafios futuros.\n\n'
          'Skill desbloqueada: ARGUMENTAÇÃO FINAL\n'
          'Efeito: reduz o dano causado pelo inimigo por 2 turnos.';
    });
  }

  void resetGame() {
    setState(() {
      playerHp = 100;
      bossHp = 120;
      dinheiro = 20;
      bossDefeated = false;
      rewardReceived = false;
      explorationStep = 0;
      bossDebuffTurns = 0;
      inventory = ['Cura', 'Cura'];
      skills = [];
      currentQuestion = 0;
      correctAnswers = 0;
      mode = 'npcIntro';
      storyText =
          'Você acorda desnorteado em um banco próximo ao Bloco H15.\n\n'
          'O campus está vazio, escuro e silencioso. As luzes piscam ao longe.\n\n'
          'À sua frente, uma figura encapuzada observa em silêncio.';
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
          icon: Icon(icon ?? Icons.auto_fix_high),
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
          'H15',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
                    color: Color(0xFF38BDF8),
                    width: 1.2,
                  ),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'STATUS DO ALUNO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Divider(color: Color(0xFF38BDF8)),
                      hpBar(
                        label: '❤️ Vida',
                        hp: playerHp,
                        maxHp: 100,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      if (mode == 'battle')
                        hpBar(
                          label: '👨‍🏫 Maligno',
                          hp: bossHp,
                          maxHp: 120,
                          color: Colors.purpleAccent,
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
    if (mode == 'npcIntro') {
      return Column(
        children: [
          rpgButton(
            text: 'Perguntar o nome',
            icon: Icons.person_search,
            onPressed: askNpcName,
          ),
          rpgButton(
            text: 'Perguntar objetivo',
            icon: Icons.flag,
            onPressed: askNpcObjective,
          ),
          rpgButton(
            text: 'Perguntar onde estou',
            icon: Icons.location_on,
            onPressed: askNpcLocation,
          ),
          rpgButton(
            text: 'Continuar',
            icon: Icons.arrow_forward,
            onPressed: continueAfterNpc,
          ),
        ],
      );
    }

    if (mode == 'explore') {
      return Column(
        children: [
          rpgButton(
            text: 'Explorar o H15',
            icon: Icons.explore,
            onPressed: exploreH15,
          ),
          rpgButton(
            text: 'Reiniciar',
            icon: Icons.restart_alt,
            onPressed: resetGame,
          ),
        ],
      );
    }

    if (mode == 'noiseChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Se esconder',
            icon: Icons.visibility_off,
            onPressed: hideFromNoise,
          ),
          rpgButton(
            text: 'Ir atrás do barulho',
            icon: Icons.hearing,
            onPressed: followNoise,
          ),
        ],
      );
    }

    if (mode == 'choice') {
      return Column(
        children: [
          rpgButton(
            text: 'Responder perguntas',
            icon: Icons.quiz,
            onPressed: startQuiz,
          ),
          rpgButton(
            text: 'Batalha por turnos',
            icon: Icons.sports_martial_arts,
            onPressed: startBattle,
          ),
        ],
      );
    }

    if (mode == 'quiz') {
      final question = questions[currentQuestion];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFFE5E7EB),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < question['options'].length; i++)
            rpgButton(
              text: question['options'][i],
              icon: Icons.arrow_right,
              onPressed: () => answerQuestion(i),
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
            text: 'Usar Cura',
            icon: Icons.healing,
            onPressed: useHeal,
          ),
          rpgButton(
            text: 'Usar habilidade',
            icon: Icons.bolt,
            onPressed: skills.isEmpty ? null : useSkill,
          ),
          rpgButton(
            text: 'Fugir indisponível contra chefe',
            icon: Icons.block,
            onPressed: null,
          ),
        ],
      );
    }

    if (mode == 'reward') {
  return Column(
    children: [
      rpgButton(
        text: rewardReceived ? 'Recompensa recebida' : 'Receber recompensa',
        icon: Icons.card_giftcard,
        onPressed: rewardReceived ? null : receiveReward,
      ),

      if (rewardReceived)
        rpgButton(
          text: 'Ir para a Politécnica',
          icon: Icons.calculate,
          onPressed: goToPolitecnica,
        ),

      rpgButton(
        text: 'Reiniciar',
        icon: Icons.restart_alt,
        onPressed: resetGame,
      ),
    ],
  );
}

    return const SizedBox.shrink();
  }
}