import 'dart:math';
import 'package:flutter/material.dart';
import 'auditorio_screen.dart';

class H06Screen extends StatefulWidget {
  final String playerName;
  final String playerGender;

  const H06Screen({
    super.key,
    required this.playerName,
    required this.playerGender,
  });

  @override
  State<H06Screen> createState() => _H06ScreenState();
}

class _H06ScreenState extends State<H06Screen> {
  int playerHp = 100;
  int maxHp = 100;
  int bossHp = 160;
  int dinheiro = 80;

  bool bossDefeated = false;
  bool rewardReceived = false;
  bool commentsUnlocked = false;

  int currentQuestion = 0;
  int correctAnswers = 0;

  List<String> inventory = ['Cura', 'Café Energético'];
  List<String> skills = ['Raciocínio Lógico', 'Gestão de Tempo'];

  String mode = 'intro';

  String get playerTitle {
    return widget.playerGender == 'feminino' ? 'Aluna' : 'Aluno';
  }

  late String storyText;

  @override
  void initState() {
    super.initState();

    storyText =
        '${widget.playerName} chega ao prédio H06.\n\n'
        'O local parece mais remoto e isolado que os outros blocos. O ar é frio, pesado e cortante.\n\n'
        'Dentro do laboratório, várias telas exibem uma tela azul de logon. O barulho dos aparelhos de ar-condicionado domina o ambiente, tornando tudo desconfortável e hostil.';
  }

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Em programação, para que serve uma variável?',
      'comment': '// Variáveis guardam valores que podem ser usados depois no código.',
      'options': [
        'Para armazenar dados durante a execução do programa',
        'Para desligar o computador',
        'Para criar imagens automaticamente',
      ],
      'answer': 0,
    },
    {
      'question': 'O que é uma função?',
      'comment': '// Funções agrupam comandos para executar uma tarefa específica.',
      'options': [
        'Um bloco de código que executa uma tarefa',
        'Uma falha do sistema operacional',
        'Um tipo de monitor',
      ],
      'answer': 0,
    },
    {
      'question': 'O que significa um erro de sintaxe?',
      'comment': '// Erro de sintaxe acontece quando o código está escrito fora das regras da linguagem.',
      'options': [
        'Um erro na escrita do código',
        'Um erro causado pela internet',
        'Um problema no teclado mecânico',
      ],
      'answer': 0,
    },
    {
      'question': 'Qual estrutura permite repetir comandos?',
      'comment': '// Laços de repetição executam o mesmo bloco várias vezes.',
      'options': [
        'Loop',
        'Comentário',
        'Imagem',
      ],
      'answer': 0,
    },
    {
      'question': 'O que é Clean Code?',
      'comment': '// Clean Code busca deixar o código claro, organizado e fácil de manter.',
      'options': [
        'Código limpo, legível e organizado',
        'Código sem nenhuma cor na tela',
        'Código que apaga arquivos sozinho',
      ],
      'answer': 0,
    },
  ];

  void exploreH06() {
    setState(() {
      storyText =
          '${widget.playerName} avança pelo laboratório do H06.\n\n'
          'As máquinas estão ligadas, mas não há ninguém usando os computadores. Nas telas, janelas de erro piscam como se algo estivesse tentando compilar o próprio ambiente.\n\n'
          'Perto de uma bancada, um estudante mexe em um código fonte cheio de comentários.';
      mode = 'programmerIntro';
    });
  }

  void talkToProgrammer() {
    setState(() {
      storyText =
          'Programador: "Ei, ${widget.playerName}, você entende de código?"\n\n'
          'Programador: "Me dá uma opinião sobre meu projeto antes da aula? Todas as funções estão comentadas."\n\n'
          'Ele vira o notebook em sua direção. O código parece confuso, mas os comentários explicam parte da lógica.';
      mode = 'programmerChoice';
    });
  }

  void readCode() {
    setState(() {
      commentsUnlocked = true;

      storyText =
          '$playerTitle ${widget.playerName}: "Claro, deixa eu ver seu código."\n\n'
          'Você analisa o código do Programador. Apesar da bagunça, os comentários ajudam a entender a lógica das funções.\n\n'
          'Programador: "Boa. Se encontrar O Compilador, preste atenção nos comentários. Eles podem salvar você de uma classificação errada."\n\n'
          'Comentários desbloqueados para o desafio contra o chefe.';
      mode = 'beforeBoss';
    });
  }

  void ignoreCode() {
    setState(() {
      commentsUnlocked = false;

      storyText =
          '$playerTitle ${widget.playerName}: "Comentário é perda de tempo."\n\n'
          'O Programador fecha o notebook lentamente e encara você com decepção.\n\n'
          'Programador: "Corajoso. Errado, provavelmente. Mas corajoso."\n\n'
          'Você seguirá para o desafio sem comentários de ajuda.';
      mode = 'beforeBoss';
    });
  }

  void meetBoss() {
    setState(() {
      storyText =
          'O laboratório escurece por alguns segundos.\n\n'
          'No fundo da sala, uma figura surge entre telas azuis e linhas de erro. Metade do corpo parece falhar em pixels, como se sua existência estivesse corrompida.\n\n'
          'O Compilador segura um teclado mecânico como arma. Cada tecla pressionada ecoa como uma sentença.\n\n'
          'O Compilador: "${widget.playerName}... execução detectada."\n\n'
          'O Compilador: "Sou a barreira técnica. Eu corrompo progresso fraco e elimino código mal escrito."\n\n'
          'O Compilador: "Se deseja a Assinatura Técnica, prove que entende mais do que teoria."\n\n'
          'O Compilador: "Escolha seu método de validação."';
      mode = 'choice';
    });
  }

  void startQuiz() {
    setState(() {
      currentQuestion = 0;
      correctAnswers = 0;
      mode = 'quiz';

      if (commentsUnlocked) {
        storyText =
            '$playerTitle ${widget.playerName}: "Vou analisar o código com calma."\n\n'
            'Você escolheu responder ao desafio técnico do Compilador.\n\n'
            'Graças aos comentários do Programador, algumas pistas aparecerão durante as perguntas.';
      } else {
        storyText =
            '$playerTitle ${widget.playerName}: "Vou resolver sem ajuda."\n\n'
            'Você escolheu responder ao desafio técnico do Compilador.\n\n'
            'Sem comentários no código, as perguntas serão mais difíceis de interpretar.';
      }
    });
  }

  void startBattle() {
    setState(() {
      mode = 'battle';

      storyText =
          '$playerTitle ${widget.playerName}: "Não vou deixar você corromper meu progresso."\n\n'
          'Você escolheu enfrentar O Compilador em batalha por turnos.\n\n'
          'O Compilador: "Modo combate iniciado. Preparando falha crítica."';
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
              '${widget.playerName} acertou todas as perguntas.\n\n'
              'O Compilador trava por alguns segundos, incapaz de encontrar erros.\n\n'
              'O Compilador: "Código aceito... impossível."\n\n'
              'Você recebe a Assinatura Técnica sem precisar lutar.';
        } else {
          mode = 'battle';

          int penaltyDamage = commentsUnlocked ? 0 : 20;
          if (penaltyDamage > 0) {
            playerHp -= penaltyDamage;
          }

          storyText =
              '${widget.playerName} errou pelo menos uma pergunta.\n\n'
              'O Compilador: "Erro detectado. Iniciando correção forçada."\n\n';

          if (!commentsUnlocked) {
            storyText +=
                'Por ter ignorado os comentários do código, você sofre uma penalidade inicial.\n\n'
                'Dano recebido: $penaltyDamage\n'
                'Vida atual: $playerHp/$maxHp';
          }
        }
      }
    });
  }

  void playerAttack() {
    setState(() {
      int damage = 25;

      if (skills.contains('Raciocínio Lógico')) {
        damage += 10;
      }

      bossHp -= damage;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'reward';

        storyText =
            '${widget.playerName} derrotou O Compilador.\n\n'
            'As telas azuis apagam uma por uma. O ruído dos computadores diminui, e o laboratório finalmente fica em silêncio.\n\n'
            'O Compilador: "Progresso... validado."';
        return;
      }

      bossTurn();
    });
  }

  void useSkill() {
    setState(() {
      if (!skills.contains('Raciocínio Lógico')) {
        storyText =
            '${widget.playerName} ainda não possui Raciocínio Lógico.\n\n'
            'O Compilador: "Habilidade inexistente. Tentativa inválida."';
        return;
      }

      int damage = commentsUnlocked ? 55 : 45;

      bossHp -= damage;

      if (bossHp <= 0) {
        bossHp = 0;
        bossDefeated = true;
        mode = 'reward';

        storyText =
            '${widget.playerName} usou Raciocínio Lógico e derrotou O Compilador.\n\n'
            'A sequência de erros entra em colapso, e o código finalmente compila.';
        return;
      }

      storyText =
          '${widget.playerName} usou Raciocínio Lógico.\n\n'
          'Dano causado: $damage\n'
          'Vida do Compilador: $bossHp';

      bossTurn();
    });
  }

  void useHeal() {
    setState(() {
      if (inventory.contains('Cura')) {
        inventory.remove('Cura');
        playerHp += 30;

        if (playerHp > maxHp) {
          playerHp = maxHp;
        }

        storyText =
            '${widget.playerName} usou uma Cura.\n\n'
            'Sua vida foi restaurada em 30 pontos.\n'
            'Vida atual: $playerHp/$maxHp';
      } else if (inventory.contains('Café Energético')) {
        inventory.remove('Café Energético');
        playerHp += 20;

        if (playerHp > maxHp) {
          playerHp = maxHp;
        }

        storyText =
            '${widget.playerName} usou um Café Energético.\n\n'
            'O foco retorna por alguns instantes.\n'
            'Vida atual: $playerHp/$maxHp';
      } else {
        storyText =
            '${widget.playerName} tentou usar um item de recuperação, mas o inventário está vazio.\n\n'
            'O Compilador: "Sem recursos. Péssima gestão."';
      }
    });
  }

  void bossTurn() {
    final random = Random();

    final bool bossMissed = random.nextInt(100) < 45;

    if (bossMissed) {
      storyText =
          'O Compilador tenta atingir ${widget.playerName} com uma sequência de erros, mas falha.\n\n'
          'Sua vida: $playerHp/$maxHp\n'
          'Vida do Compilador: $bossHp';
      return;
    }

    int damage = commentsUnlocked ? 18 : 28;

    playerHp -= damage;

    if (playerHp <= 0) {
      loseGame();
    } else {
      storyText =
          'O Compilador acerta ${widget.playerName} com um ataque de falha crítica.\n\n'
          'Dano recebido: $damage\n'
          'Sua vida: $playerHp/$maxHp\n'
          'Vida do Compilador: $bossHp';
    }
  }

  void loseGame() {
    setState(() {
      playerHp = maxHp;
      bossHp = 160;
      bossDefeated = false;
      rewardReceived = false;
      commentsUnlocked = false;
      currentQuestion = 0;
      correctAnswers = 0;
      inventory = ['Cura'];
      skills = ['Raciocínio Lógico', 'Gestão de Tempo'];
      mode = 'intro';

      storyText =
          '${widget.playerName} foi derrotado no H06.\n\n'
          'De repente, as telas azuis piscam e tudo reinicia.\n\n'
          'Você abre os olhos novamente na entrada do laboratório, com a sensação de que o próprio sistema restaurou sua tentativa.';
    });
  }

  void receiveReward() {
    setState(() {
      if (!rewardReceived) {
        inventory.add('IDE');
        skills.add('Clean Code');
        rewardReceived = true;
      }

      storyText =
          '${widget.playerName} recebeu a recompensa do H06!\n\n'
          'Assinatura obtida: Assinatura Técnica\n\n'
          'Item desbloqueado: IDE\n'
          'Efeito: melhora a organização e análise de código em desafios futuros.\n\n'
          'Skill desbloqueada: Clean Code\n'
          'Efeito: reduz falhas e melhora ataques técnicos em batalhas futuras.';
    });
  }

  void goToAuditorio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuditorioScreen(
          playerName: widget.playerName,
          playerGender: widget.playerGender,
        ),
      ),
    );
  }

  void resetArea() {
    setState(() {
      playerHp = maxHp;
      bossHp = 160;
      dinheiro = 80;
      bossDefeated = false;
      rewardReceived = false;
      commentsUnlocked = false;
      currentQuestion = 0;
      correctAnswers = 0;
      inventory = ['Cura', 'Café Energético'];
      skills = ['Raciocínio Lógico', 'Gestão de Tempo'];
      mode = 'intro';

      storyText =
          '${widget.playerName} chega ao prédio H06.\n\n'
          'O local parece mais remoto e isolado que os outros blocos. O ar é frio, pesado e cortante.\n\n'
          'Dentro do laboratório, várias telas exibem uma tela azul de logon. O barulho dos aparelhos de ar-condicionado domina o ambiente, tornando tudo desconfortável e hostil.';
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

  Widget statusText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  String getCurrentQuestionText() {
    final question = questions[currentQuestion];

    if (commentsUnlocked) {
      return '${question['comment']}\n\n${question['question']}';
    }

    return question['question'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'H06 — Laboratório Corrompido',
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
              Color(0xFF111827),
              Color(0xFF1E293B),
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
                      Text(
                        'STATUS DE ${widget.playerName.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Divider(color: Color(0xFF38BDF8)),
                      hpBar(
                        label: '❤️ Vida',
                        hp: playerHp,
                        maxHp: maxHp,
                        color: Colors.redAccent,
                      ),
                      statusText('💰 Dinheiro: $dinheiro créditos'),
                      statusText(
                        '🎒 Inventário: ${inventory.isEmpty ? "Vazio" : inventory.join(", ")}',
                      ),
                      statusText(
                        '⚡ Skills: ${skills.isEmpty ? "Nenhuma" : skills.join(", ")}',
                      ),
                      if (commentsUnlocked)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '💬 Comentários desbloqueados',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (mode == 'battle')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: hpBar(
                            label: '⌨️ O Compilador',
                            hp: bossHp,
                            maxHp: 160,
                            color: Colors.purpleAccent,
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
            text: 'Explorar H06',
            icon: Icons.computer,
            onPressed: exploreH06,
          ),
          rpgButton(
            text: 'Reiniciar área',
            icon: Icons.restart_alt,
            onPressed: resetArea,
          ),
        ],
      );
    }

    if (mode == 'programmerIntro') {
      return Column(
        children: [
          rpgButton(
            text: 'Conversar com Programador',
            icon: Icons.code,
            onPressed: talkToProgrammer,
          ),
        ],
      );
    }

    if (mode == 'programmerChoice') {
      return Column(
        children: [
          rpgButton(
            text: 'Claro, deixa eu ver seu código',
            icon: Icons.visibility,
            onPressed: readCode,
          ),
          rpgButton(
            text: 'Comentário é perda de tempo',
            icon: Icons.block,
            onPressed: ignoreCode,
          ),
        ],
      );
    }

    if (mode == 'beforeBoss') {
      return Column(
        children: [
          rpgButton(
            text: 'Enfrentar O Compilador',
            icon: Icons.memory,
            onPressed: meetBoss,
          ),
        ],
      );
    }

    if (mode == 'choice') {
      return Column(
        children: [
          rpgButton(
            text: 'Responder desafio técnico',
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
            getCurrentQuestionText(),
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
            text: 'Usar item de recuperação',
            icon: Icons.healing,
            onPressed: useHeal,
          ),
          rpgButton(
            text: 'Usar Raciocínio Lógico',
            icon: Icons.psychology,
            onPressed:
                skills.contains('Raciocínio Lógico') ? useSkill : null,
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
              text: 'Ir para o Auditório',
              icon: Icons.theater_comedy,
              onPressed: goToAuditorio,
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