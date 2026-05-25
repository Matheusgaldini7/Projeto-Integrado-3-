import 'dart:math' as math;
import '../models/Ambiente.dart';
import '../data/AmbientesMock.dart';

class ProgressoService {
  static final ProgressoService _instance = ProgressoService._internal();
  factory ProgressoService() => _instance;
  ProgressoService._internal();

  final Set<String> _vencidos = {};

  List<Ambiente> get ambientes => ambientesMock;

  // Ordem obrigatória dos chefes (refeitório fora — é área de cura)
  static const List<String> ordemChefes = [
    'h15',
    'politecnica',
    'h06',
    'auditorio',
  ];

  bool sequenciaLiberada(String id) {
    if (id == 'refeitorio') return true;
    final idx = ordemChefes.indexOf(id);
    if (idx <= 0) return true;
    return _vencidos.contains(ordemChefes[idx - 1]);
  }

  bool dentroDoRaio({required String ambienteId, required double latAtual, required double lngAtual}) {
    final a = ambientesMock.firstWhere((x) => x.id == ambienteId);
    return _distancia(latAtual, lngAtual, a.latitude, a.longitude) <= a.raioMetros;
  }

  double distanciaAte({required String ambienteId, required double latAtual, required double lngAtual}) {
    final a = ambientesMock.firstWhere((x) => x.id == ambienteId);
    return _distancia(latAtual, lngAtual, a.latitude, a.longitude);
  }

  bool podeEntrar({required String ambienteId, required double latAtual, required double lngAtual}) {
    return sequenciaLiberada(ambienteId) &&
        dentroDoRaio(ambienteId: ambienteId, latAtual: latAtual, lngAtual: lngAtual);
  }

  void registrarVitoria(String id) => _vencidos.add(id);
  bool foiVencido(String id) => _vencidos.contains(id);

  Ambiente? get proximoDestino {
    for (final id in ordemChefes) {
      if (!_vencidos.contains(id)) {
        return ambientesMock.firstWhere((a) => a.id == id);
      }
    }
    return null;
  }

  double direcaoParaDestino({
    required double latAtual, required double lngAtual,
    required double latAlvo, required double lngAlvo,
  }) {
    final dLng = lngAlvo - lngAtual;
    final dLat = latAlvo - latAtual;
    final angulo = math.atan2(dLng, dLat) * 180 / math.pi;
    return (angulo + 360) % 360;
  }

  double _distancia(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
