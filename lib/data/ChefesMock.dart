import '../models/Chefe.dart';

const Map<String, Chefe> chefesMock = {
  'maligno': Chefe(id: 'maligno', nome: 'Maligno', titulo: 'Professor Avaliador',
    hpMax: 100, ataque: 18, sprite: '👨‍🏫',
    falaInicio: 'Você chegou até aqui… mas ainda há uma escolha a ser feita.',
    falaDerrota: 'Impressionante… você passou pela minha avaliação.',
    falaVitoria: 'Insuficiente. Volte quando estiver preparado.'),
  'derivador': Chefe(id: 'derivador', nome: 'O Derivador', titulo: 'Professor de Cálculo',
    hpMax: 140, ataque: 24, sprite: '🧮',
    falaInicio: 'A lógica não perdoa erros. Vamos ver sua precisão.',
    falaDerrota: 'Sua solução foi... elegante. Bem calculada.',
    falaVitoria: 'Teorema provado: você não passa.'),
  'compilador': Chefe(id: 'compilador', nome: 'O Compilador', titulo: 'Professor de Programação',
    hpMax: 160, ataque: 28, sprite: '💻',
    falaInicio: 'Er_r0: aluno detectado. Iniciando análise...',
    falaDerrota: 'Build: SUCCESS. Você passou na revisão.',
    falaVitoria: 'ERRO FATAL: conhecimento insuficiente.'),
  'reitor': Chefe(id: 'reitor', nome: 'Magnífico', titulo: 'Reitor das Sombras',
    hpMax: 220, ataque: 35, sprite: '🎓',
    falaInicio: 'Mais um aluno... O sistema não aceita erros.',
    falaDerrota: 'Seu esforço foi... notável. O diploma é seu.',
    falaVitoria: 'REPROVADO. O ciclo continua.'),
};
