enum TipoEfeito { xpBoost, reducaoDano, esquiva}

class Skill {
  final String id;
  final String nome;
  final String descricao;
  final TipoEfeito tipo;
  final double valor;

  const Skill({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.valor,
  });


  factory Skill.fromFirestore(String id, Map<String, dynamic> data) {
    return Skill(
      id: id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      tipo: TipoEfeito.values.firstWhere(
        (e) => e.name == (data['tipo'] ?? 'xpBoost'), 
        orElse: () => TipoEfeito.xpBoost
      ),
      valor: (data['valor'] as num).toDouble(),
    );
  }
}