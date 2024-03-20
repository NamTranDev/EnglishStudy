import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/progress_audio.dart';
import 'package:english_study/reuse/ad_interstitial_view_model.dart';
import 'package:english_study/reuse/audio_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';

class ConversationViewModel with AudioViewModel, AdInterstitialViewModel {
  final ValueNotifier<ProgressBarAudio?> _progressStatus =
      ValueNotifier<ProgressBarAudio?>(null);
  ValueNotifier<ProgressBarAudio?> get progressStatus => _progressStatus;

  Future<Conversation?> conversationDetail(Conversation? _conversation) async {
    var db = getIt<DBProvider>();
    showAd();
    var conversation =
        _conversation?.audios != null && _conversation?.transcript != null
            ? _conversation
            : await db.getConversationDetail(_conversation?.id?.toString());
    var total = await initAudio(conversation?.audios?.getOrNull(0));
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

  void dispose() {
    disposeAd();
    disposeAudio();
  }
}
