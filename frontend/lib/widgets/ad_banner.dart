import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  final String adUnitId; // 広告ユニットIDを引数で受け取る

  const AdBanner({Key? key, required this.adUnitId}) : super(key: key);

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId, // 引数で受け取ったIDを使用
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          debugPrint('BannerAd loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: ${widget.adUnitId} - $err');
          ad.dispose();
        },
        // 必要に応じて他のイベントリスナーも追加
        onAdOpened: (ad) => debugPrint('BannerAd opened.'),
        onAdClosed: (ad) => debugPrint('BannerAd closed.'),
        onAdImpression: (ad) => debugPrint('BannerAd impression.'),
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center, // 広告を中央に配置
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      // 広告がロードされていない場合は、プレースホルダーを表示するか、何も表示しない
      return const SizedBox.shrink(); // 何も表示しない
      // または、広告を待っている間に少し高さを確保したい場合
      // return SizedBox(
      //   width: AdSize.banner.width.toDouble(),
      //   height: AdSize.banner.height.toDouble(),
      //   child: Center(
      //     child: CircularProgressIndicator(), // ロード中のインジケーター
      //   ),
      // );
    }
  }
}
