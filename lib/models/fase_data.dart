import 'package:flutter/widgets.dart';
import 'player.dart';

class FaseData {
  final String nome;
  final String subtitulo;
  final String id;
  final String imagem;
  final int requisito;
  final Widget Function(Player player) tela;

  const FaseData({
    required this.nome,
    required this.subtitulo,
    required this.id,
    required this.imagem,
    required this.requisito,
    required this.tela,
  });
}
