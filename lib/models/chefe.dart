class Chefe {
  final String nome;
  final String assinatura;
  final String local;
  final int ordem;
  final int vida;
  final int ataque;
  final String recompensaItem;
  final String recompensaSkill;

  Chefe({
    required this.nome,
    required this.assinatura,
    required this.local,
    required this.ordem,
    required this.vida,
    required this.ataque,
    required this.recompensaItem,
    required this.recompensaSkill,
  });

  factory Chefe.fromMap(Map<String, dynamic> map) {
    return Chefe(
      nome: map['nome'],
      assinatura: map['assinatura'],
      local: map['local'],
      ordem: map['ordem'],
      vida: map['vida'],
      ataque: map['ataque'],
      recompensaItem: map['recompensaItem'],
      recompensaSkill: map['recompensaSkill'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'assinatura': assinatura,
      'local': local,
      'ordem': ordem,
      'vida': vida,
      'ataque': ataque,
      'recompensaItem': recompensaItem,
      'recompensaSkill': recompensaSkill,
    };
  }
}