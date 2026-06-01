class Player {
  final String nome;
  final String genero;
  int hp;
  int fasesVencidas;
  int dinheiro;
  List<String> inventario;
  List<String> skills;

  Player({
    required this.nome,
    required this.genero,
    this.hp = 100,
    this.fasesVencidas = 0,
    this.dinheiro = 20,
    List<String>? inventario,
    List<String>? skills,
  })  : inventario = inventario ?? ['Cura'],
        skills = skills ?? [];

  String get titulo => genero == 'feminino' ? 'Aluna' : 'Aluno';

  // +20 HP máximo por fase vencida
  int get hpMax => 100 + (fasesVencidas * 20);

  // +10 de ataque por fase vencida
  int get bonusAtaque => fasesVencidas * 10;

  Player copyWith({
    int? hp,
    int? fasesVencidas,
    int? dinheiro,
    List<String>? inventario,
    List<String>? skills,
  }) =>
      Player(
        nome: nome,
        genero: genero,
        hp: hp ?? this.hp,
        fasesVencidas: fasesVencidas ?? this.fasesVencidas,
        dinheiro: dinheiro ?? this.dinheiro,
        inventario: inventario ?? List.from(this.inventario),
        skills: skills ?? List.from(this.skills),
      );

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'genero': genero,
        'hp': hp,
        'fasesVencidas': fasesVencidas,
        'dinheiro': dinheiro,
        'inventario': inventario,
        'skills': skills,
      };

  factory Player.fromMap(Map<String, dynamic> m) => Player(
        nome: m['nome'] as String,
        genero: m['genero'] as String,
        hp: m['hp'] as int,
        fasesVencidas: m['fasesVencidas'] as int? ?? 0,
        dinheiro: m['dinheiro'] as int? ?? 20,
        inventario: List<String>.from(m['inventario'] ?? ['Cura']),
        skills: List<String>.from(m['skills'] ?? []),
      );
}