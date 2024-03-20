
import 'package:english_study/reuse/component/banner_component.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/memory.dart';

mixin AdInterstitialViewModel {
  final AdController _adController = AdController();
  AdController get adController => _adController;

  void showAd({int? max}) {
    if (getIt<AppMemory>().checkShowAdInterested(max ?? 1)) {
      _adController.showInterstitial();
    }
  }

  void disposeAd() {
    _adController.dispose();
  }
}
