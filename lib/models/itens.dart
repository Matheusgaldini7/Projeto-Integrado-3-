class ItemBatalha {
  final String nome;
  final String emoji;
  final String descricao;
  final int cooldownTurnos;
  final int curaValor;
  final bool armaCritico;
  final int escudoValor;

  bool get cura => curaValor > 0;
  bool get escudo => escudoValor > 0;

  const ItemBatalha({
    required this.nome,
    required this.emoji,
    required this.descricao,
    required this.cooldownTurnos,
    this.curaValor = 0,
    this.armaCritico = false,
    this.escudoValor = 0,
  });

  factory ItemBatalha.fromFirestore(String id, Map<String, dynamic> data) {
    return ItemBatalha(
      nome: data['nome'] ?? id,
      emoji: data['emoji'] ?? '❓',
      descricao: data['descricao'] ?? '',
      cooldownTurnos: data['cooldownTurnos'] ?? 4,
      curaValor: data['curaValor'] ?? 0,
      armaCritico: data['armaCritico'] ?? false,
      escudoValor: data['escudoValor'] ?? 0,
    );
  }
}