import 'package:english_study/model/audio.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:just_audio/just_audio.dart';

mixin AudioViewModel {
  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio(Audio? audio) async {
    try {
      initAudio(audio);
      audioPlayer.play();
    } catch (e) {
      print(e);
    }
  }

  Future<Duration?> initAudio(Audio? audio) async {
    var path = "${getIt<AppMemory>().pathFolderDocument}/${audio?.path}";
    try {
      var fileExist = await doesFileExist(path);
      if (fileExist) {
        return await audioPlayer.setFilePath(path);
      } else {
        return await audioPlayer.setAsset('assets/audio/${audio?.name}');
      }
    } catch (e) {
      print(e);
    }
    print(path);
  }

  void disposeAudio() {
    audioPlayer.stop();
  }
}
