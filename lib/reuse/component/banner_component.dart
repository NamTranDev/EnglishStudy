import 'package:english_study/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerComponent extends StatefulWidget {
  final AdController? controller;

  const BannerComponent({super.key, this.controller});

  @override
  State<BannerComponent> createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(() {
      switch (widget.controller?.adInterstitialStatus) {
        case 1:
          _loadInterstitialAd();
          break;
        case 2:
          _interstitialAd?.show();
          break;
      }
    });

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              widget.controller?.refresh();
            },
          );

          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd == null
        ? const SizedBox()
        : SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}

class AdController extends ChangeNotifier {
  int adInterstitialStatus = 0;

  void loadInterstitial() {
    adInterstitialStatus = 1;
    notifyListeners();
  }

  void showInterstitial() {
    adInterstitialStatus = 2;
    notifyListeners();
  }

  void refresh() {
    adInterstitialStatus = 0;
  }
}
