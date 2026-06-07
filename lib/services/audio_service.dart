import 'audio_manager.dart';

class AudioService {

  static double _volumeEfeitos = 0.8;

  static Future<void> init() async {
    await AudioManager.init();
  }

  static Future<void> setSomAtivado(
    bool ativado,
  ) async {

    await AudioManager.setMuted(
      !ativado,
    );
  }

  static Future<void> setVolumeMusica(
    double volume,
  ) async {

    await AudioManager.setVolume(
      volume,
    );
  }

  static Future<void> setVolumeEfeitos(
    double volume,
  ) async {

    _volumeEfeitos = volume;
  }

  static double get volumeEfeitos =>
      _volumeEfeitos;

  static Future<void> dispose() async {
    await AudioManager.dispose();
  }
}