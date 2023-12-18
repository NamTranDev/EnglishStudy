import 'package:english_study/model/audio.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/progress_audio.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ConversationViewModel with AudioViewModel {
  final ValueNotifier<ProgressBarAudio?> _progressStatus =
      ValueNotifier<ProgressBarAudio?>(null);
  ValueNotifier<ProgressBarAudio?> get progressStatus => _progressStatus;

  Future<Conversation> conversationDetail(String? id) async {
    var db = getIt<DBProvider>();
    var conversation = await db.getConversationDetail(id);
    var total = await initAudio(conversation.audios?.getOrNull(0));
    _progressStatus.value =
        ProgressBarAudio(current: Duration(seconds: 0), total: total);
    audioPlayer.positionStream.listen((event) {
      var duration = event as Duration?;
      var currentProgress = _progressStatus.value;
      _progressStatus.value =
          ProgressBarAudio(current: duration, total: currentProgress?.total);
    });
    return conversation;
  }

  void playOrPause() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }

  void seekAudio(int duration) {
    audioPlayer.seek(Duration(seconds: duration));
  }

  void refresh(String? id) {
    var db = getIt<DBProvider>();
    db.syncConversation(id);
    audioPlayer.pause();
    audioPlayer.seek(Duration.zero);
  }
}
