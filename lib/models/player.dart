import 'chefe.dart';

class Player {
  final String nickname;
  final String genero;

  int hp;
  int hpMax;
  int dinheiro;
  int ataque;
  int nivel;
  int xp;

  bool som;
  double volumeMusica;
  double volumeEfeitos;

  List<String> inventario;
  List<String> skills;
  List<String> assinaturas;

  Player({
    required this.nickname,
    required this.genero,
    this.hp = 100,
    this.hpMax = 100,
    this.dinheiro = 20,
    this.ataque = 15,
    this.nivel = 1,
    this.xp = 0,
    this.som = true,
    this.volumeMusica = 0.7,
    this.volumeEfeitos = 0.8,
    List<String>? inventario,
    List<String>? skills,
    List<String>? assinaturas,
  })  : inventario = inventario ?? ['Cura'],
        skills = skills ?? [],
        assinaturas = assinaturas ?? [];

  String get titulo => genero == 'feminino' ? 'Aluna' : 'Aluno';

  int get xpParaProximoNivel => nivel * 100;

  bool get morto => hp <= 0;

  Player ganharXp(int valor) {
    int novoXp = xp + valor;
    int novoNivel = nivel;
    int novoHpMax = hpMax;
    int novoAtaque = ataque;
    int novoDinheiro = dinheiro;
    List<String> novasSkills = List.from(skills);

    final Map<int, String> skillsConfig = {
      2: 'funciona_na_maquina', // esquiva 15%
      3: 'gestao_tempo', // 20% xp
      4: 'leitura_codigo', // 25% redução dano
    };

    while (novoXp >= (novoNivel * 100)) {
      novoXp -= (novoNivel * 100);
      novoNivel++;
      
      novoHpMax += 20;
      novoAtaque += 5;
      novoDinheiro += 10;
      
      if (skillsConfig.containsKey(novoNivel)) {
        String skill = skillsConfig[novoNivel]!;
        if (!novasSkills.contains(skill)) {
          novasSkills.add(skill);
        }
      }
    }

    return copyWith(
      xp: novoXp,
      nivel: novoNivel,
      hpMax: novoHpMax,
      hp: novoHpMax,
      ataque: novoAtaque,
      dinheiro: novoDinheiro,
      skills: novasSkills,
    );
  }

  Player copyWith({
    int? hp,
    int? hpMax,
    int? dinheiro,
    int? ataque,
    int? nivel,
    int? xp,
    bool? som,
    double? volumeMusica,
    double? volumeEfeitos,
    List<String>? inventario,
    List<String>? skills,
    List<String>? assinaturas,
  }) {
    return Player(
      nickname: nickname,
      genero: genero,
      hp: hp ?? this.hp,
      hpMax: hpMax ?? this.hpMax,
      dinheiro: dinheiro ?? this.dinheiro,
      ataque: ataque ?? this.ataque,
      nivel: nivel ?? this.nivel,
      xp: xp ?? this.xp,
      som: som ?? this.som,
      volumeMusica: volumeMusica ?? this.volumeMusica,
      volumeEfeitos: volumeEfeitos ?? this.volumeEfeitos,
      inventario: inventario ?? List.from(this.inventario),
      skills: skills ?? List.from(this.skills),
      assinaturas: assinaturas ?? List.from(this.assinaturas),
    );
  }

  Map<String, dynamic> toMap() => {
        'nickname': nickname,
        'genero': genero,
        'hp': hp,
        'hpMax': hpMax,
        'dinheiro': dinheiro,
        'ataque': ataque,
        'nivel': nivel,
        'xp': xp,
        'som': som,
        'volumeMusica': volumeMusica,
        'volumeEfeitos': volumeEfeitos,
        'inventario': inventario,
        'skills': skills,
        'assinaturas': assinaturas,
      };

  factory Player.fromMap(Map<String, dynamic> m) {
    return Player(
      nickname: m['nickname'] as String? ?? '',
      genero: m['genero'] as String? ?? '',
      hp: m['hp'] as int? ?? 100,
      hpMax: m['hpMax'] as int? ?? 100,
      dinheiro: m['dinheiro'] as int? ?? 20,
      ataque: m['ataque'] as int? ?? 15,
      nivel: m['nivel'] as int? ?? 1,
      xp: m['xp'] as int? ?? 0,
      som: m['som'] as bool? ?? true,
      volumeMusica: (m['volumeMusica'] as num?)?.toDouble() ?? 0.7,
      volumeEfeitos: (m['volumeEfeitos'] as num?)?.toDouble() ?? 0.8,
      inventario: List<String>.from(m['inventario'] ?? ['Cura']),
      skills: List<String>.from(m['skills'] ?? []),
      assinaturas: List<String>.from(m['assinaturas'] ?? []),
    );
  }

  Player aplicarRecompensa(
    Chefe chefe, {
    int? xpCustom,
  }) {
    final novasAssinaturas =
        List<String>.from(
            assinaturas);
    if(
      chefe.assinatura.isNotEmpty &&
      !novasAssinaturas.contains(
        chefe.assinatura
      )
    ){
      novasAssinaturas.add(
        chefe.assinatura
      );

    }
    final novoInventario =
        List<String>.from(
            inventario);
    if(
      !novoInventario.contains(
        chefe.recompensaItem
      )
    ){
      novoInventario.add(
        chefe.recompensaItem
      );
    }
    return ganharXp(
      xpCustom ??
      chefe.recompensaXp
    ).copyWith(
      inventario:
          novoInventario,
      assinaturas:
          novasAssinaturas,
    );
  }
  bool temSkill(
    String skillId,
  ){

    return skills.contains(
      skillId,
    );

  }
}