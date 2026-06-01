import 'package:audioplayers/audioplayers.dart';

// ─────────────────────────────────────────────────────────────────
// COMO ADICIONAR O SOM:
//  1. Coloque seu arquivo de música em:  assets/audio/trilha.mp3
//  2. Descomente a linha marcada com [ATIVAR MÚSICA] abaixo.
// ─────────────────────────────────────────────────────────────────

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _somAtivado = true;
  static double _volumeMusica = 0.3;

  static Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_volumeMusica);
    // [ATIVAR MÚSICA] Descomente a linha abaixo após adicionar o arquivo:
    // await _player.play(AssetSource('audio/trilha.mp3'));
  }

  static Future<void> setSomAtivado(bool ativado) async {
    _somAtivado = ativado;
    await _player.setVolume(ativado ? _volumeMusica : 0);
  }

  static Future<void> setVolumeMusica(double volume) async {
    _volumeMusica = volume;
    if (_somAtivado) await _player.setVolume(volume);
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
