import '../data/perguntas_data.dart';

class QuizService {
  final List<Pergunta> perguntas;
  int _corretas = 0;
  int _indiceAtual = 0;

  QuizService(this.perguntas);

  bool responder(int escolha) {
    if (escolha == perguntas[_indiceAtual].respostaCorreta) {
      _corretas++;
    }
    _indiceAtual++;
    return _indiceAtual >= perguntas.length;
  }

  bool get venceu => _corretas == perguntas.length;
  Pergunta get perguntaAtual => perguntas[_indiceAtual];
}