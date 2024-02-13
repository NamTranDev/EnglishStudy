import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:english_study/audio/notifier/progress_notifier.dart';
import 'package:english_study/audio/player_manager.dart';
import 'package:english_study/constants.dart';
import 'package:flutter/cupertino.dart';
import '../../../services/service_locator.dart';

class AudioProgressBar extends StatelessWidget {
  final PlayerManager player;
  const AudioProgressBar({Key? key, required this.player}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: player.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          timeLabelLocation: TimeLabelLocation.none,
          barHeight: 2,
          baseBarColor: maastricht_blue,
          progressBarColor: turquoise,
          thumbColor: turquoise,
          thumbRadius: 8,
          thumbGlowRadius: 5,
          progress: value.current,
          // buffered: value.buffered,
          total: value.total,
          onSeek: player.seek,
        );
      },
    );
  }
}
