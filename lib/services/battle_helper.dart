import 'dart:math';
import '../models/player.dart';
import '../models/chefe.dart';
import '../data/itens_repository.dart';
import '../data/skills_repository.dart';
import '../models/skill.dart';

enum TipoAtaque { normal, critico, critEspecial, miss }

class AtaqueResult {
  final int dano;
  final TipoAtaque tipo;
  final String mensagem;
  const AtaqueResult({required this.dano, required this.tipo, required this.mensagem});
}

class _ItemState {
  int turnoUltimoUso;
  _ItemState() : turnoUltimoUso = -999;
}

class ResultadoBatalha {
  final int danoChefe;
  final int danoPlayer;
  final int hpPlayerFinal;
  final String mensagemJogador;
  final String mensagemChefe;

  ResultadoBatalha({
    required this.danoChefe,
    required this.danoPlayer,
    required this.hpPlayerFinal,
    required this.mensagemJogador,
    required this.mensagemChefe,
  });
}

class ResultadoItem {
  final int novoHp;
  final String mensagem;
  final bool estaMorto;

  ResultadoItem({
    required this.novoHp,
    required this.mensagem,
    required this.estaMorto,
  });
}

class BattleHelper {
  final Random _rng = Random();
  final int bonusAtaque;
  final List<String> skillsAtivas;

  int turno = 0;
  bool proximoAtaqueCriticoEspecial = false;
  int escudoAtivo = 0;

  int _ataquesJ = 0, _missJ = 0, _cicloJ = 0;
  int _ataquesC = 0, _missC = 0, _cicloC = 0;

  final Map<String, _ItemState> _itemStates = {};

  BattleHelper({required this.bonusAtaque, this.skillsAtivas = const []});

  double _somarSkill(TipoEfeito tipo){
    double total = 0;
    for(final id in skillsAtivas){
      final skill = SkillsRepository.getSkill(id);
      if(skill == null) continue;
      if(skill.tipo == tipo){
        total += skill.valor;
      }
    }
    return total;
  }

  bool itemDisponivel(String nome) {
    final item = ItensRepository.getItem(nome);
    if (item == null) return false;
    final state = _itemStates[nome];
    if (state == null) return true;
    return turno - state.turnoUltimoUso >= item.cooldownTurnos;
  }

  int turnosParaItem(String nome) {
    final item = ItensRepository.getItem(nome);
    if (item == null) return 0;
    final state = _itemStates[nome];
    if (state == null) return 0;
    final cd = item.cooldownTurnos - (turno - state.turnoUltimoUso);
    return cd < 0 ? 0 : cd;
  }

  (String mensagem, int cura) usarItem(String nome) {
    final item = ItensRepository.getItem(nome);
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
    final reducao =
      _somarSkill(
        TipoEfeito.reducaoDano
      ).clamp(
        0.0,
        0.90,
      );
    if(reducao > 0){
      dano = (
          dano * (1 - reducao)
      ).round();
    }
    String sufixo = '';
    if (escudoAtivo > 0) {
      final absorvido = dano < escudoAtivo ? dano : escudoAtivo;
      dano -= absorvido;
      escudoAtivo -= absorvido;
      sufixo = ' (🧮 escudo absorveu $absorvido!)';
    }
    final esquiva = _somarSkill(
      TipoEfeito.esquiva
    );
    if(
      esquiva > 0 &&
      _rng.nextDouble() < esquiva
    )
    {
      return const AtaqueResult(
          dano:0,
          tipo:TipoAtaque.miss,
          mensagem:'Você desviou do ataque!'
      );

    }
    return AtaqueResult(dano: dano,
        tipo: critico ? TipoAtaque.critico : TipoAtaque.normal,
        mensagem: critico
            ? 'CRÍTICO do chefe! $dano de dano!$sufixo'
            : 'O chefe causou $dano de dano.$sufixo');
  }

  ResultadoItem processarTurnoComItem(String nomeItem, Player player, Chefe chefe) {
    final (msgItem, cura) = usarItem(nomeItem);
    
    int hpPosCura = (player.hp + cura).clamp(0, player.hpMax);
    
    incrementarTurno();
    final c = atacarChefe(chefe.ataque);
    
    int hpFinal = (hpPosCura - c.dano).clamp(0, player.hpMax);
    
    return ResultadoItem(
      novoHp: hpFinal,
      mensagem: "$msgItem\n\n${c.mensagem}",
      estaMorto: hpFinal <= 0,
    );
}

  ResultadoBatalha processarAtaque({
    required Player player,
    required Chefe chefe,
    double multJogador = 1.0,
    double multChefe = 1.0,
  }) {

    final r = atacarJogador();
    int danoNoChefe = r.dano;

    if (r.tipo != TipoAtaque.miss) {
      danoNoChefe = (danoNoChefe * multJogador).round();
    }

    incrementarTurno();
    final c = atacarChefe((chefe.ataque * multChefe).round());

    int hpPlayerFinal = (player.hp - c.dano).clamp(0, player.hpMax);

    return ResultadoBatalha(
      danoChefe: danoNoChefe,
      danoPlayer: c.dano,
      hpPlayerFinal: hpPlayerFinal,
      mensagemJogador: r.mensagem,
      mensagemChefe: c.mensagem,
    );
  }

  void incrementarTurno() => turno++;
}