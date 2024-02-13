import 'package:english_study/audio/notifier/repeat_button_notifier.dart';
import 'package:english_study/audio/player_manager.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class RepeatButton extends StatelessWidget {
  final PlayerManager player;
  const RepeatButton({super.key, required this.player});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: player.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = Icon(Icons.repeat, color: maastricht_blue.withAlpha(125));
            break;
          case RepeatState.repeatSong:
            icon = const Icon(
              Icons.repeat_one,
              color: maastricht_blue,
            );
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(
              Icons.repeat,
              color: maastricht_blue,
            );
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: player.repeat,
        );
      },
    );
  }
}
