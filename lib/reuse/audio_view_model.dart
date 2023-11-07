import 'package:english_study/model/audio.dart';
import 'package:english_study/model/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:just_audio/just_audio.dart';

mixin AudioViewModel {
  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio(Audio? audio) {
    audioPlayer.stop();
    var path =
        "${getIt<AppMemory>().pathFolderDocument}/CEFR_Wordlist/audio/${audio?.path}";
    print(path);
    try {
      audioPlayer.setFilePath(path);
      audioPlayer.play();
    } catch (e) {
      print(e);
    }
  }
}
