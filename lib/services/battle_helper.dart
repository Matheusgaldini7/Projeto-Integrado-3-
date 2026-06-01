import 'dart:math';

enum TipoAtaque { normal, critico, critEspecial, miss }

class AtaqueResult {
  final int dano;
  final TipoAtaque tipo;
  final String mensagem;
  const AtaqueResult({required this.dano, required this.tipo, required this.mensagem});
}

class ItemBatalha {
  final String nome;
  final String descricao;
  final String emoji;
  final int cooldownTurnos;
  final bool cura;
  final int curaValor;
  final bool armaCritico;
  final bool escudo;
  final int escudoValor;

  const ItemBatalha({
    required this.nome,
    required this.descricao,
    required this.emoji,
    this.cooldownTurnos = 4,
    this.cura = false,
    this.curaValor = 0,
    this.armaCritico = false,
    this.escudo = false,
    this.escudoValor = 0,
  });
}

const Map<String, ItemBatalha> catalogoItens = {
  'Cura': ItemBatalha(
    nome: 'Cura', descricao: '+30 HP', emoji: '💊',
    cooldownTurnos: 4, cura: true, curaValor: 30,
  ),
  'Café Energético': ItemBatalha(
    nome: 'Café Energético', descricao: '+30 HP + CRÍTICO ESPECIAL',
    emoji: '☕', cooldownTurnos: 4, cura: true, curaValor: 30, armaCritico: true,
  ),
  'Caneta da Aprovação': ItemBatalha(
    nome: 'Caneta da Aprovação', descricao: 'CRÍTICO ESPECIAL (35-50)',
    emoji: '✏️', cooldownTurnos: 3, armaCritico: true,
  ),
  'Calculadora': ItemBatalha(
    nome: 'Calculadora', descricao: 'Escudo absorve 20 de dano',
    emoji: '🧮', cooldownTurnos: 4, escudo: true, escudoValor: 20,
  ),
  'IDE': ItemBatalha(
    nome: 'IDE', descricao: '+20 HP + CRÍTICO ESPECIAL',
    emoji: '💻', cooldownTurnos: 3, cura: true, curaValor: 20, armaCritico: true,
  ),
  'Diploma': ItemBatalha(
    nome: 'Diploma', descricao: 'Cura HP total',
    emoji: '🎓', cooldownTurnos: 6, cura: true, curaValor: 9999,
  ),
};

class _ItemState {
  int turnoUltimoUso;
  _ItemState() : turnoUltimoUso = -999;
}

class BattleHelper {
  final Random _rng = Random();
  final int bonusAtaque;

  int turno = 0;
  bool proximoAtaqueCriticoEspecial = false;
  int escudoAtivo = 0;

  int _ataquesJ = 0, _missJ = 0, _cicloJ = 0;
  int _ataquesC = 0, _missC = 0, _cicloC = 0;

  final Map<String, _ItemState> _itemStates = {};

  BattleHelper({required this.bonusAtaque});

  bool itemDisponivel(String nome) {
    final item = catalogoItens[nome];
    if (item == null) return false;
    final state = _itemStates[nome];
    if (state == null) return true;
    return turno - state.turnoUltimoUso >= item.cooldownTurnos;
  }

  int turnosParaItem(String nome) {
    final item = catalogoItens[nome];
    if (item == null) return 0;
    final state = _itemStates[nome];
    if (state == null) return 0;
    final cd = item.cooldownTurnos - (turno - state.turnoUltimoUso);
    return cd < 0 ? 0 : cd;
  }

  (String mensagem, int cura) usarItem(String nome) {
    final item = catalogoItens[nome];
    if (item == null) return ('Item desconhecido.', 0);
    _itemStates[nome] ??= _ItemState();
    _itemStates[nome]!.turnoUltimoUso = turno;
    final partes = <String>[];
    int curaTotal = 0;
    if (item.cura && item.curaValor > 0) {
      curaTotal = item.curaValor;
      partes.add('${item.emoji} ${item.nome}! +$curaTotal HP.');
    } else {
      partes.add('${item.emoji} ${item.nome} usado!');
    }
    if (item.armaCritico) {
      proximoAtaqueCriticoEspecial = true;
      partes.add('Próximo ataque: CRÍTICO ESPECIAL (35-50)!');
    }
    if (item.escudo) {
      escudoAtivo = item.escudoValor;
      partes.add('Escudo: absorve até ${item.escudoValor} de dano!');
    }
    return (partes.join(' '), curaTotal);
  }

  AtaqueResult atacarJogador() {
    if (proximoAtaqueCriticoEspecial) {
      proximoAtaqueCriticoEspecial = false;
      _ataquesJ++; _cicloJ++;
      if (_cicloJ >= 6) { _cicloJ = 0; _missJ = 0; }
      final dano = 35 + _rng.nextInt(16);
      return AtaqueResult(dano: dano, tipo: TipoAtaque.critEspecial,
          mensagem: 'CRÍTICO ESPECIAL! $dano de dano!');
    }
    _ataquesJ++; _cicloJ++;
    final cabem = 2 - _missJ;
    final restantes = 6 - (_cicloJ - 1);
    if (cabem > 0 && _rng.nextInt(restantes) < cabem) {
      _missJ++;
      if (_cicloJ >= 6) { _cicloJ = 0; _missJ = 0; }
      return const AtaqueResult(dano: 0, tipo: TipoAtaque.miss,
          mensagem: 'Você atacou... mas errou!');
    }
    if (_cicloJ >= 6) { _cicloJ = 0; _missJ = 0; }
    final critico = _ataquesJ % 5 == 0;
    final base = 15 + _rng.nextInt(6) + bonusAtaque;
    final dano = critico ? (base * 1.5).round() : base;
    return AtaqueResult(dano: dano,
        tipo: critico ? TipoAtaque.critico : TipoAtaque.normal,
        mensagem: critico
            ? 'CRÍTICO! $dano de dano! (bônus: +$bonusAtaque)'
            : 'Você causou $dano de dano.');
  }

  AtaqueResult atacarChefe(int ataqueBase) {
    _ataquesC++; _cicloC++;
    final cabem = 2 - _missC;
    final restantes = 6 - (_cicloC - 1);
    if (cabem > 0 && _rng.nextInt(restantes) < cabem) {
      _missC++;
      if (_cicloC >= 6) { _cicloC = 0; _missC = 0; }
      return AtaqueResult(dano: 0, tipo: TipoAtaque.miss,
          mensagem: 'O chefe atacou... mas errou!');
    }
    if (_cicloC >= 6) { _cicloC = 0; _missC = 0; }
    final critico = _ataquesC % 5 == 0;
    final base = ataqueBase - 4 + _rng.nextInt(9);
    int dano = critico ? (base * 1.5).round() : base;
    String sufixo = '';
    if (escudoAtivo > 0) {
      final absorvido = dano < escudoAtivo ? dano : escudoAtivo;
      dano -= absorvido;
      escudoAtivo -= absorvido;
      sufixo = ' (🧮 escudo absorveu $absorvido!)';
    }
    return AtaqueResult(dano: dano,
        tipo: critico ? TipoAtaque.critico : TipoAtaque.normal,
        mensagem: critico
            ? 'CRÍTICO do chefe! $dano de dano!$sufixo'
            : 'O chefe causou $dano de dano.$sufixo');
  }

  void incrementarTurno() => turno++;
}