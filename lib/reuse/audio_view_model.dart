import 'package:english_study/model/audio.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:just_audio/just_audio.dart';

mixin AudioViewModel {
  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio(Audio? audio) async {
    // audioPlayer.stop();
    var path =
        "${getIt<AppMemory>().pathFolderDocument}/${getIt<Preference>().currentCategory()}/${audio?.folderName}/audio/${audio?.path}";
    print(path);
    try {
      var fileExist = await doesFileExist(path);
      if (fileExist) {
        audioPlayer.setFilePath(path);
      } else {
        audioPlayer.setAsset('assets/audio/${audio?.path}');
      }
      audioPlayer.play();
    } catch (e) {
      print(e);
    }
  }

  void disposeAudio() {
    audioPlayer.stop();
  }
}
