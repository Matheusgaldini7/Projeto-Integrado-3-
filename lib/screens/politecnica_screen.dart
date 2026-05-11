import 'dart:math';
import 'package:flutter/material.dart';
import 'refeitorio_screen.dart';

class PolitecnicaScreen extends StatefulWidget {
  final String playerName;
  final String playerGender;

  const PolitecnicaScreen({
    super.key,
    required this.playerName,
    required this.playerGender,
  });

  @override
  State<PolitecnicaScreen> createState() => _PolitecnicaScreenState();
}

class _PolitecnicaScreenState extends State<PolitecnicaScreen> {

  String get playerTitle {
    return widget.playerGender == 'feminino' ? 'Aluna' : 'Aluno';
  }
  
  int playerHp = 100;
  int bossHp = 140;
  int dinheiro = 40;

  bool bossDefeated = false;
  bool rewardReceived = false;
  bool puzzleBonus = false;

  int currentQuestion = 0;
  int correctAnswers = 0;

  List<String> inventory = ['Cura'];
  List<String> skills = [];

  String mode = 'intro';

  String storyText =
      'Você chega à Politécnica.\n\n'
      'O ambiente é tomado por computadores, bancadas de engenharia e quadros cobertos por fórmulas matemáticas.\n\n'
      'O som constante das máquinas cria um clima futurista e desconfortável.';

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Quanto é 2 + 3?',
      'options': ['5', '6', '8'],
      'answer': 0,
    },
    {
      'question': 'Qual operação representa uma multiplicação?',
      'options': ['+', 'x', '-'],
      'answer': 1,
    },
    {
      'question': 'Qual é o resultado de 10 dividido por 2?',
      'options': ['2', '5', '10'],
      'answer': 1,
    },
    {
      'question': 'Em lógica, o valor verdadeiro também pode ser representado por:',
      'options': ['0', '1', '-1'],
      'answer': 1,
    },
    {
      'question': 'Qual alternativa representa melhor o raciocínio lógico?',
      'options': [
        'Resolver problemas seguindo etapas',
        'Escolher respostas aleatórias',
        'Ignorar os dados do problema',
      ],
      'answer': 0,
    },
  ];

  void talkToEngineer() {
    setState(() {
      storyText =
          'Você encontra um NPC Engenheiro próximo a um terminal ligado.\n\n'
          'Engenheiro: "Os cálculos são traiçoeiros. Use a lógica antes de enfrentar O Derivador."\n\n'
          'Engenheiro: "Você pode tentar resolver um enigma agora. Se acertar, terá vantagem contra O Derivador."';
      mode = 'engineerChoice';
    });
  }

  void tryPuzzle() {
    setState(() {
      storyText =
          '$playerTitle ${widget.playerName}: "Quero tentar"\n\n'
          'O terminal exibe um enigma simples:\n\n'
          '"Se uma máquina produz 4 peças por minuto, quantas peças ela produz em 5 minutos?"';
      mode = 'puzzle';
    });
  }

  void answerPuzzle(int selectedIndex) {
    setState(() {
      if (selectedIndex == 1) {
        puzzleBonus = true;
        bossHp = 110;

        storyText =
            'Você acertou o enigma.\n\n'
            'Engenheiro: "Muito bom ${widget.playerName}. Você ainda sabe pensar sob pressão."\n\n'
            'O Derivador começará a batalha enfraquecido.';
      } else {
        puzzleBonus = false;

        storyText =
            'Você errou o enigma.\n\n'
            'Engenheiro: "A lógica estava perto ${widget.playerName}, mas você se perdeu no caminho."\n\n'
            'Você seguirá sem vantagem contra O Derivador.';
      }

      mode = 'beforeBoss';
    });
  }

  void fightDirectly() {
    setState(() {
      puzzleBonus = false;

      storyText =
          'Você decide ignorar o enigma e seguir direto para o confronto.\n\n'
          'Engenheiro: "Coragem sem preparo também é uma fórmula. Só não costuma dar bons resultados."\n\n'
          'O Derivador aguarda no centro do laboratório.';
      mode = 'beforeBoss';
    });
  }

  void meetBoss() {
  setState(() {
    storyText =
        'O laboratório da CEATEC fica em silêncio por alguns segundos.\n\n'
        'Diante do quadro principal, uma figura alta e magra surge entre fórmulas e símbolos matemáticos. '
        'Suas mãos lembram compassos, e seus movimentos são rígidos, quase geométricos.\n\n'
        'O Derivador: "Você superou a primeira avaliação, mas agora ${widget.playerName}, você está diante da verdadeira barreira matemática do curso."\n\n'
        'O Derivador: "Eu guardo a Assinatura da Lógica. Para avançar, você precisará provar precisão, raciocínio rápido e controle sob pressão."\n\n'
        'O Derivador: "A teoria pura sempre supera a prática improvisada... diferente do que aquele programador do H06 insiste em dizer."\n\n'
        'O Derivador: ergue uma das mãos, e teoremas começam a se formar no ar como lâminas de luz.\n\n'
        'O Derivador: "Escolha como deseja ser avaliado."';

    mode = 'choice';
  });
}

  void startQuiz() {
    setState(() {
      currentQuestion = 0;
      correctAnswers = 0;
      mode = 'quiz';

      storyText =
          '$playerTitle ${widget.playerName}: "Vou ganhar de você em seu próprio jogo"\n\n'
          'Você escolheu responder às perguntas do Derivador.\n\n'
          'Acerte todas para receber a Assinatura da Lógica.';
    });
  }

  void startBattle() {
    setState(() {
      mode = 'battle';

      storyText =
          '$playerTitle ${widget.playerName}: "Prepare-se. Eu vou enfrentar você."\n\n'
          'Você escolheu enfrentar O Derivador em batalha por turnos.\n\n'
          'As fórmulas no quadro começam a brilhar.';
    });
  }

  void goToRefeitorio() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => RefeitorioScreen(
        playerName: widget.playerName,
        playerGender: widget.playerGender,
      ),
    ),
  );
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
              'Você acertou todas as perguntas.\n\n'
              'O Derivador reconhece seu raciocínio e entrega o boletim sem lutar.';
        } else {
          mode = 'battle';

          storyText =
              'Você errou pelo menos uma pergunta.\n\n'
              'O Derivador: "A lógica falhou. Agora veremos sua resistência."';
        }
      }
    });
  }

  void playerAttack() {
    setState(() {
      int damage = puzzleBonus ? 35 : 25;

      bossHp -= damage;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'reward';

        storyText =
            'Você derrotou O Derivador.\n\n'
            'As fórmulas no quadro desaparecem e o laboratório fica em silêncio.';
        return;
      }

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
            'A matemática não perdoa inventário vazio.';
      }
    });
  }

  void useSkill() {
    setState(() {
      if (skills.isEmpty) {
        storyText =
            'Você ainda não possui nenhuma habilidade nesta área.\n\n'
            'Por enquanto, só resta confiar no básico.';
        return;
      }

      bossHp -= 45;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'reward';

        storyText =
            'Você usou Raciocínio Lógico e derrotou O Derivador.\n\n'
            'A lógica venceu a pressão.';
        return;
      }

      bossTurn();
    });
  }

  void bossTurn() {
    final random = Random();

    final bool bossMissed = random.nextInt(100) < 50;

    if (bossMissed) {
      storyText =
          'O Derivador tentou atacar com uma equação impossível, mas errou.\n\n'
          'Sua vida: $playerHp\n'
          'Vida do Professor de Cálculo: $bossHp';
      return;
    }

    int damage = puzzleBonus ? 15 : 25;

    playerHp -= damage;

    if (playerHp <= 0) {
      loseGame();
    } else {
      storyText =
          'O Derivador acertou um ataque.\n\n'
          'Dano recebido: $damage\n'
          'Sua vida: $playerHp\n'
          'Vida do O Derivador: $bossHp';
    }
  }

  void loseGame() {
    setState(() {
      playerHp = 100;
      bossHp = 140;
      dinheiro = 20;
      bossDefeated = false;
      rewardReceived = false;
      puzzleBonus = false;
      currentQuestion = 0;
      correctAnswers = 0;
      inventory = ['Cura'];
      skills = [];
      mode = 'intro';

      storyText =
          'Você foi derrotado.\n\n'
          'De repente, abre os olhos novamente na entrada da Politécnica.\n\n'
          'Você não sabe se falhou em um cálculo... ou se o próprio sistema recalculou sua tentativa.';
    });
  }

  void receiveReward() {
    setState(() {
      if (!rewardReceived) {
        inventory.add('Calculadora');
        skills.add('Raciocínio Lógico');
        rewardReceived = true;
      }

      storyText =
          'Recompensa recebida!\n\n'
          'Item desbloqueado: Calculadora\n'
          'Efeito: auxilia em desafios de lógica e matemática.\n\n'
          'Skill desbloqueada: Raciocínio Lógico\n'
          'Efeito: aumenta o dano de um ataque especial.';
    });
  }

  void resetArea() {
    setState(() {
      playerHp = 100;
      bossHp = 140;
      bossDefeated = false;
      rewardReceived = false;
      puzzleBonus = false;
      currentQuestion = 0;
      correctAnswers = 0;
      inventory = ['Cura', 'Cura'];
      skills = [];
      mode = 'intro';

      storyText =
          'Você chega à Politécnica.\n\n'
          'O ambiente é tomado por computadores, bancadas de engenharia e quadros cobertos por fórmulas matemáticas.\n\n'
          'O som constante das máquinas cria um clima futurista e desconfortável.';
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
          'Politécnica — Laboratório da Lógica',
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
                          label: '📐 O Derivador',
                          hp: bossHp,
                          maxHp: 140,
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
                      if (puzzleBonus)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '🧠 Bônus de lógica ativo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
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
            text: 'Explorar laboratório',
            icon: Icons.precision_manufacturing,
            onPressed: talkToEngineer,
          ),
          rpgButton(
            text: 'Reiniciar área',
            icon: Icons.restart_alt,
            onPressed: resetArea,
          ),
        ],
      );
    }

    if (mode == 'engineerChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Quero tentar resolver',
            icon: Icons.psychology,
            onPressed: tryPuzzle,
          ),
          rpgButton(
            text: 'Prefiro lutar direto',
            icon: Icons.sports_martial_arts,
            onPressed: fightDirectly,
          ),
        ],
      );
    }

    if (mode == 'puzzle') {
  return Column(
    children: [
      rpgButton(
        text: '10 peças',
        icon: Icons.arrow_right,
        onPressed: () => answerPuzzle(0),
      ),
      rpgButton(
        text: '20 peças',
        icon: Icons.arrow_right,
        onPressed: () => answerPuzzle(1),
      ),
      rpgButton(
        text: '25 peças',
        icon: Icons.arrow_right,
        onPressed: () => answerPuzzle(2),
      ),
    ],
  );
}

    if (mode == 'beforeBoss') {
      return Column(
        children: [
          rpgButton(
            text: 'Enfrentar O Derivador',
            icon: Icons.calculate,
            onPressed: meetBoss,
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
              text: 'Ir para o Refeitório',
              icon: Icons.restaurant,
              onPressed: goToRefeitorio,
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