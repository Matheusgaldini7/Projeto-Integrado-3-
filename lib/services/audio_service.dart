import 'audio_manager.dart';

class AudioService {
  static Future<void> init() async {
    await AudioManager.init();
  }

  static Future<void> setSomAtivado(bool ativado) async {
    await AudioManager.setMuted(!ativado);
  }

  static Future<void> setVolumeMusica(double volume) async {
    await AudioManager.setVolume(volume);
  }

  static Future<void> dispose() async {
    await AudioManager.dispose();
  }
}
