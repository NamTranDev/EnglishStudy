import 'package:english_study/logger.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/sync_data/check_update_background_task.dart';
import 'package:english_study/utils/extension.dart';

class SplashViewModel {
  Future initialize() async {
    logger('initialize');
    var updateVersion = await getUpdateVersion();
    var currentVersion = getIt<Preference>().versionUpdate();
    logger(currentVersion);
    if (currentVersion < (updateVersion?.version ?? 0)) {
      getIt<AppMemory>().isHasUpdate.value = true;
      for (int i = currentVersion; i < (updateVersion?.version ?? 0); i++) {
        var key = updateVersion?.urls?.getOrNull(i)?.name;
        var db = getIt<DBProvider>();
        var isHasExistCategory = await db.checkCategoryExist(key);
        if (isHasExistCategory == true) {
          await db.deleteAllDataRelate(key);
        }
      }
    }
  }
}
