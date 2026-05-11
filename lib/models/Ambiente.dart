class Ambiente {
  final String id;
  final String nome;
  final String descricao;
  final double latitude;
  final double longitude;
  final double raioMetros;
  final int ordem;
  final String chefe;
  final String itemRecompensa;
  final String skillRecompensa;

  const Ambiente({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
    required this.ordem,
    required this.chefe,
    required this.itemRecompensa,
    required this.skillRecompensa,
  });
}
