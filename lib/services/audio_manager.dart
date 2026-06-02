import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static String? _currentTrack;
  static bool _muted = false;

  static const String _explorationPath = 'audio/bgm/exploration_theme.mp3';
  static const String _battlePath = 'audio/bgm/battle_theme.mp3';
  static const double _explorationVolume = 0.35;
  static const double _battleVolume = 0.4;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  static Future<void> playExplorationMusic() async {
    if (_currentTrack == _explorationPath) return;
    _currentTrack = _explorationPath;
    await _player.stop();
    await _player.setVolume(_muted ? 0.0 : _explorationVolume);
    await _player.play(AssetSource(_explorationPath));
  }

  static Future<void> playBattleMusic() async {
    if (_currentTrack == _battlePath) return;
    _currentTrack = _battlePath;
    await _player.stop();
    await _player.setVolume(_muted ? 0.0 : _battleVolume);
    await _player.play(AssetSource(_battlePath));
  }

  static Future<void> stopMusic() async {
    _currentTrack = null;
    await _player.stop();
  }

  static Future<void> setMuted(bool muted) async {
    _muted = muted;
    if (muted) {
      await _player.setVolume(0.0);
    } else {
      final vol =
          _currentTrack == _battlePath ? _battleVolume : _explorationVolume;
      await _player.setVolume(vol);
    }
  }

  static Future<void> setVolume(double volume) async {
    if (!_muted) await _player.setVolume(volume);
  }

  static Future<void> dispose() async {
    _initialized = false;
    _currentTrack = null;
    await _player.dispose();
  }
}
