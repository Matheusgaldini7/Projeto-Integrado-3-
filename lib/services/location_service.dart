import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class Ambiente {
  final String id;
  final String nome;
  final double latitude;
  final double longitude;
  final double raioMetros;

  const Ambiente({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.raioMetros,
  });
}

const List<Ambiente> ambientesPUC = [
  Ambiente(id: 'h15',         nome: 'Bloco H15',               latitude: -22.8340787, longitude: -47.05264678, raioMetros: 40),
  Ambiente(id: 'politecnica', nome: 'Politécnica (H12)',        latitude: -22.8321815, longitude: -47.05178261, raioMetros: 40),
  Ambiente(id: 'refeitorio',  nome: 'Refeitório — Zona Segura', latitude: -22.8330204, longitude: -47.05207273, raioMetros: 40),
  Ambiente(id: 'h06',         nome: 'Bloco H06',                latitude: -22.8345598, longitude: -47.05278316, raioMetros: 40),
  Ambiente(id: 'auditorio',   nome: 'Auditório D. Gilberto',    latitude: -22.8332033, longitude: -47.05302799, raioMetros: 40),
];

class LocationService {
  static Future<Position> currentPosition() => obterPosicao();

  static Future<Position> obterPosicao() async {
    final ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) throw Exception('GPS desativado. Ative o GPS do celular.');
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw Exception('Permissão negada.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception('Permissão negada permanentemente.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation),
    );
  }

  static Future<double> distanciaAtualAte(
      double destinoLat, double destinoLon) async {
    final position = await currentPosition();
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      destinoLat,
      destinoLon,
    );
  }

  static Future<String> direcao(double destinoLat, double destinoLon) async {
    final position = await currentPosition();
    final bearing = _bearing(
      position.latitude,
      position.longitude,
      destinoLat,
      destinoLon,
    );
    return _formatDirection(bearing);
  }

  static double distancia(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static bool dentroDoRaio(Position pos, Ambiente a) =>
      distancia(pos.latitude, pos.longitude, a.latitude, a.longitude) <=
      a.raioMetros;

  static double distanciaAte(Position pos, String id) {
    final a = ambientesPUC.firstWhere((x) => x.id == id);
    return distancia(pos.latitude, pos.longitude, a.latitude, a.longitude);
  }

  static double _bearing(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _degreesToRadians(lat1);
    final phi2 = _degreesToRadians(lat2);
    final deltaLambda = _degreesToRadians(lon2 - lon1);
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    return (_radiansToDegrees(math.atan2(y, x)) + 360) % 360;
  }

  static String _formatDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees < 67.5) return 'NE';
    if (degrees < 112.5) return 'L';
    if (degrees < 157.5) return 'SE';
    if (degrees < 202.5) return 'S';
    if (degrees < 247.5) return 'SO';
    if (degrees < 292.5) return 'O';
    return 'NO';
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;
  static double _radiansToDegrees(double radians) => radians * 180.0 / math.pi;
}
