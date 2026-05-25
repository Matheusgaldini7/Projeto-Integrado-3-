import 'package:flutter/material.dart';
import '../models/player.dart';
import '../screens/auditorio_screen.dart';
import '../screens/h06_screen.dart';
import '../screens/h15_screen.dart';
import '../screens/politecnica_screen.dart';

class FaseData {
  final String nome;
  final String id;
  final String imagem;
  final int requisito;
  final double latitude;
  final double longitude;
  final double raioMetros;
  final Widget Function(Player) tela;

  const FaseData({
    required this.nome,
    required this.id,
    required this.imagem,
    required this.requisito,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
    required this.tela,
  });
}

final fases = <FaseData>[
  FaseData(
    nome: 'H15',
    id: 'h15',
    imagem: 'assets/backgrounds/h15_img.png',
    requisito: 0,
    latitude: -22.8340787,
    longitude: -47.05264678,
    raioMetros: 40,
    tela: (player) => H15Screen(player: player),
  ),
  FaseData(
    nome: 'Politecnica',
    id: 'politecnica',
    imagem: 'assets/backgrounds/ct.png',
    requisito: 1,
    latitude: -22.8321815,
    longitude: -47.05178261,
    raioMetros: 40,
    tela: (player) => PolitecnicaScreen(player: player),
  ),
  FaseData(
    nome: 'H06',
    id: 'h06',
    imagem: 'assets/backgrounds/h06.png',
    requisito: 2,
    latitude: -22.8345598,
    longitude: -47.05278316,
    raioMetros: 40,
    tela: (player) => H06Screen(player: player),
  ),
  FaseData(
    nome: 'Auditorio',
    id: 'auditorio',
    imagem: 'assets/backgrounds/auditorio.png',
    requisito: 3,
    latitude: -22.8332033,
    longitude: -47.05302799,
    raioMetros: 40,
    tela: (player) => AuditorioScreen(player: player),
  ),
];
