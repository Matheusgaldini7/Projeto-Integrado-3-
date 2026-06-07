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
  Ambiente(id: 'h15',         nome: 'Bloco H15',               latitude: -22.83399806779015, longitude: -47.052612488046826, raioMetros: 80),
  Ambiente(id: 'politecnica', nome: 'Politécnica (H12)',        latitude: -22.833148454425693,  longitude: -47.05257979624784, raioMetros: 80),
  Ambiente(id: 'refeitorio',  nome: 'Refeitório — Zona Segura', latitude: -22.832937462019515, longitude: -47.05214875081456, raioMetros: 80),
  Ambiente(id: 'h06',         nome: 'Bloco H06',                latitude: -22.832146799292275, longitude: -47.05056913619648, raioMetros: 80),
  Ambiente(id: 'auditorio',   nome: 'Auditório D. Gilberto',    latitude:  -22.83306155102536, longitude: -47.05312436713532, raioMetros: 40),
];   
class LocationService {
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

  static Stream<Position> monitorarPosicao() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
  }
}
