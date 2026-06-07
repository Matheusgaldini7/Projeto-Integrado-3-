class Pergunta {
  final String texto;
  final List<String> opcoes;
  final int respostaCorreta;

  Pergunta({
    required this.texto,
    required this.opcoes,
    required this.respostaCorreta,
  });
}

final Map<String, List<Pergunta>> bancoDePerguntas = {
  // Perguntas da Tela H15 (Maligno)
  'maligno': [
    Pergunta(
      texto: 'O que é um sistema de informação?',
      opcoes: [
        'Um conjunto de pessoas, processos e tecnologia para tratar informações',
        'Apenas um computador ligado à internet',
        'Um jogo instalado no celular'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'Qual destes é um exemplo de dado?',
      opcoes: [
        'Uma informação analisada',
        'O número 25 registrado em uma tabela',
        'Uma decisão tomada por um gerente'
      ],
      respostaCorreta: 1,
    ),
    Pergunta(
      texto: 'Para que serve um banco de dados?',
      opcoes: [
        'Guardar, organizar e consultar informações',
        'Melhorar o sinal do Wi-Fi',
        'Aumentar o brilho da tela'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'O que é programação?',
      opcoes: [
        'Criar instruções para o computador executar tarefas',
        'Montar fisicamente um computador',
        'Apenas usar aplicativos prontos'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'Qual é uma função da TI nas empresas?',
      opcoes: [
        'Apoiar processos, decisões e organização de dados',
        'Substituir totalmente todas as pessoas',
        'Servir apenas para entretenimento'
      ],
      respostaCorreta: 0,
    ),
  ],

  // Perguntas da Politécnica
  'derivador': [
    Pergunta(
      texto: 'Quanto é 2 + 3?',
      opcoes: ['5', '6', '8'],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'Qual operação representa uma multiplicação?',
      opcoes: ['+', 'x', '-'],
      respostaCorreta: 1,
    ),
    Pergunta(
      texto: 'Resultado de 10 dividido por 2?',
      opcoes: ['2', '5', '10'],
      respostaCorreta: 1,
    ),
    Pergunta(
      texto: 'Em lógica, verdadeiro é representado por:',
      opcoes: ['0', '1', '-1'],
      respostaCorreta: 1,
    ),
    Pergunta(
      texto: 'O que representa melhor o raciocínio lógico?',
      opcoes: [
        'Resolver problemas seguindo etapas',
        'Escolher respostas aleatórias',
        'Ignorar os dados'
      ],
      respostaCorreta: 0,
    ),
  ],
  
  // Perguntas do cehfe do h06
  'compilador': [
    Pergunta(
      texto: 'Para que serve uma variável?',
      opcoes: [
        'Armazenar dados durante a execução',
        'Desligar o computador',
        'Criar imagens automaticamente'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'O que é uma função?',
      opcoes: [
        'Um bloco de código que executa uma tarefa',
        'Uma falha do sistema',
        'Um tipo de monitor'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'O que significa erro de sintaxe?',
      opcoes: [
        'Erro na escrita do código',
        'Erro causado pela internet',
        'Problema no teclado'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'O que é clean code?',
      opcoes: [
        'Código limpo, legível e bem organizado',
        'Código sem comentários',
        'Código que apaga arquivos'
      ],
      respostaCorreta: 0,
    ),
    Pergunta(
      texto: 'Função de um comentário no código?',
      opcoes: [
        'Explicar o que o código faz',
        'Executar uma instrução extra',
        'Diminuir o arquivo'
      ],
      respostaCorreta: 0,
    ),
  ],
};