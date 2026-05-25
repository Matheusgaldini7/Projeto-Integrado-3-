import 'package:geolocator/geolocator.dart';

class LocalizacaoService {
  Future<Position> obterPosicaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) throw Exception('GPS desativado');

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw Exception('Permissao negada');
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception('Permissao negada permanentemente');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
