import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static AudioPlayer? _player;

  static AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  /// Play incoming new order chime sound
  static Future<void> playOrderReceivedSound() async {
    try {
      final p = player;
      await p.stop();
      await p.play(
        AssetSource('sounds/order_received.wav'),
        mode: PlayerMode.lowLatency,
      );
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error playing order_received sound: $e');
      try {
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// Dispose audio player when app closes
  static void dispose() {
    _player?.dispose();
    _player = null;
  }
}
