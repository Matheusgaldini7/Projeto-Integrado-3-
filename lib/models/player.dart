class Player {
  final String nome;
  final String genero;

  int hp;
  int fasesVencidas;
  int dinheiro;

  bool som;
  double volumeMusica;
  double volumeEfeitos;

  List<String> inventario;
  List<String> skills;

  Player({
    required this.nome,
    required this.genero,

    this.hp = 100,
    this.fasesVencidas = 0,
    this.dinheiro = 20,

    this.som = true,
    this.volumeMusica = 0.7,
    this.volumeEfeitos = 0.8,

    List<String>? inventario,
    List<String>? skills,
  })  : inventario = inventario ?? ['Cura'],
        skills = skills ?? [];

  String get titulo =>
      genero == 'feminino'
          ? 'Aluna'
          : 'Aluno';

  int get hpMax =>
      100 + (fasesVencidas * 20);

  int get bonusAtaque =>
      fasesVencidas * 10;

  Player copyWith({
    int? hp,
    int? fasesVencidas,
    int? dinheiro,

    bool? som,
    double? volumeMusica,
    double? volumeEfeitos,

    List<String>? inventario,
    List<String>? skills,
  }) {

    return Player(
      nome: nome,
      genero: genero,

      hp: hp ?? this.hp,

      fasesVencidas:
          fasesVencidas ??
          this.fasesVencidas,

      dinheiro:
          dinheiro ??
          this.dinheiro,

      som:
          som ??
          this.som,

      volumeMusica:
          volumeMusica ??
          this.volumeMusica,

      volumeEfeitos:
          volumeEfeitos ??
          this.volumeEfeitos,

      inventario:
          inventario ??
          List.from(this.inventario),

      skills:
          skills ??
          List.from(this.skills),
    );
  }

  Map<String, dynamic> toMap() => {

    'nome': nome,
    'genero': genero,

    'hp': hp,

    'fasesVencidas':
        fasesVencidas,

    'dinheiro':
        dinheiro,

    'som': som,

    'volumeMusica':
        volumeMusica,

    'volumeEfeitos':
        volumeEfeitos,

    'inventario':
        inventario,

    'skills':
        skills,
  };

  factory Player.fromMap(
    Map<String, dynamic> m,
  ) {

    return Player(

      nome:
          m['nome']
              as String,

      genero:
          m['genero']
              as String,

      hp:
          m['hp']
              as int? ??
          100,

      fasesVencidas:
          m['fasesVencidas']
              as int? ??
          0,

      dinheiro:
          m['dinheiro']
              as int? ??
          20,

      som:
          m['som']
              as bool? ??
          true,

      volumeMusica:
          (m['volumeMusica']
                  as num?)
              ?.toDouble() ??
          0.7,

      volumeEfeitos:
          (m['volumeEfeitos']
                  as num?)
              ?.toDouble() ??
          0.8,

      inventario:
          List<String>.from(
            m['inventario']
                ?? ['Cura'],
          ),

      skills:
          List<String>.from(
            m['skills']
                ?? [],
          ),
    );
  }
}