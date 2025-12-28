import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  bool _isMusicEnabled = true;
  double _volume = 0.5;

  bool get isMusicPlaying => _isMusicPlaying;
  bool get isMusicEnabled => _isMusicEnabled;
  double get volume => _volume;

  Future<void> init() async {
    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgMusicPlayer.setVolume(_volume);
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await _bgMusicPlayer.play(AssetSource('genelmusic.mp3'));
      _isMusicPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Müzik çalma hatası: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgMusicPlayer.stop();
    _isMusicPlaying = false;
    notifyListeners();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgMusicPlayer.pause();
    _isMusicPlaying = false;
    notifyListeners();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    await _bgMusicPlayer.resume();
    _isMusicPlaying = true;
    notifyListeners();
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;

    if (_isMusicEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }

    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _bgMusicPlayer.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _bgMusicPlayer.dispose();
    super.dispose();
  }
}
