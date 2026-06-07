class Chefe {
  final String nome;
  final String assinatura;
  final String local;
  final int ordem;
  final int hp;
  final int ataque;
  final String recompensaItem;
  final int recompensaXp;

  Chefe({
    required this.nome,
    required this.assinatura,
    required this.local,
    required this.ordem,
    required this.hp,
    required this.ataque,
    required this.recompensaItem,
    required this.recompensaXp,
  });

  factory Chefe.fromMap(Map<String, dynamic> map) {
    return Chefe(
      nome: map['nome'] ?? '',
      assinatura: map['assinatura'] ?? '',
      local: map['local'] ?? '',
      ordem: map['ordem'] ?? 0,
      hp: map['hp'] ?? 0,
      ataque: map['ataque'] ?? 0,
      recompensaItem: map['recompensaItem'] ?? '',
      recompensaXp: map['recompensaXp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'assinatura': assinatura,
      'local': local,
      'ordem': ordem,
      'hp': hp,
      'ataque': ataque,
      'recompensaItem': recompensaItem,
      'recompensaXp': recompensaXp,
    };
  }
}