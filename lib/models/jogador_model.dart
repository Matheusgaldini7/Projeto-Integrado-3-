class Jogador {
  final String genero;
  final String nome;

  Jogador({
    required this.genero,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'genero': genero,
      'vidaAtual': 100,
      'vidaMaxima': 100,
      'forca': 10,
      'resiliencia': 8,
      'agilidade': 7,
      'inteligencia': 9,
      'nivel': 1,
      'xp': 0,
      'xpProximoNivel': 100,
      'dinheiro': 0,
      'chefeAtual': 'maligno',
      'assinaturas': [],
      'areaAtual': '',
      'latitude': 0.0,
      'longitude': 0.0,
      'itens': {},
      'assinaturasIntelecto': 0,
      'assinaturasCombate': 0,
    };
  }
}