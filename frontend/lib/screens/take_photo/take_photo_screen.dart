import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/analysis_page/analysis.dart';
import 'package:frontend/widgets/back_button.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart'; // HapticFeedbackのために追加

// 位置情報取得の関数（変更なし）
Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('位置情報サービスが無効です。');
    return Future.error('位置情報サービスが無効です。');
  }

  permission = await Geolocator.checkPermission();
  debugPrint('現在の権限: $permission');
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    debugPrint('権限リクエスト後の権限: $permission');
    if (permission == LocationPermission.denied) {
      return Future.error('位置情報の権限が拒否されました。');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint('位置情報の権限が永久に拒否されています。');
    return Future.error('位置情報の権限が永久に拒否されています。');
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    debugPrint('取得した位置情報: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    debugPrint('位置情報取得中のエラー: $e');
    throw e;
  }
}

class TakePhotoScreen extends StatefulWidget {
  final String category;
  const TakePhotoScreen({super.key, required this.category});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AnimationController
  _shutterButtonAnimationController; // ⭐ アニメーションコントローラー
  late Animation<double> _shutterButtonScaleAnimation; // ⭐ 拡大縮小アニメーション

  @override
  void initState() {
    super.initState();
    _initCamera();

    // ⭐ アニメーションコントローラーの初期化
    _shutterButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // 短い時間で素早くアニメーション
    );
    // ⭐ 拡大縮小アニメーションの定義（通常サイズから少し小さく、元に戻る）
    _shutterButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _shutterButtonAnimationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _shutterButtonAnimationController.dispose(); // ⭐ アニメーションコントローラーの解放
    super.dispose();
  }

  void _handlePermissionError(String errorMessage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('エラー'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _takePicture() async {
    if (_controller.value.isTakingPicture || !_controller.value.isInitialized) {
      // 既に撮影中か、カメラが初期化されていない場合は何もしない
      return;
    }

    // ⭐ 視覚的フィードバック: ボタンアニメーション開始
    _shutterButtonAnimationController.forward().then((_) {
      _shutterButtonAnimationController.reverse();
    });

    // ⭐ 触覚フィードバック: デバイスを振動させる
    HapticFeedback.lightImpact(); // 軽く振動

    try {
      await _initializeControllerFuture;

      // 1. 写真を撮影
      final image = await _controller.takePicture();

      // 2. 位置情報を取得
      Position position;
      try {
        position = await getCurrentLocation();
      } catch (e) {
        debugPrint('位置情報の取得に失敗しました: $e');
        _handlePermissionError(e.toString());
        return; // 位置情報取得に失敗した場合は処理を中断
      }

      if (!mounted) return;

      // 3. 写真パスと位置情報を PicturePreviewScreen に渡す
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PicturePreviewScreen(
                imagePath: image.path,
                category: widget.category,
                position: position,
              ),
        ),
      );
    } catch (e) {
      debugPrint('Error taking picture: $e');
      // エラーが発生した場合もアニメーションをリセットする
      _shutterButtonAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // デバイスの画面サイズ情報を取得
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor;
    // SafeAreaのパディング情報を取得
    final EdgeInsets safeAreaPadding = mediaQuery.padding;

    // --- 各UI要素のサイズと位置を画面サイズに対する割合で計算 ---
    // 基準となる画面幅と高さを定義 (例: iPhone 8/SEの論理ピクセルサイズ)
    const double referenceWidth = 375.0;
    const double referenceHeight = 667.0;

    // --- 各UI要素の基準オフセット値と比率を定数で定義 ---
    // 吹き出し関連
    const double baseBubbleTopOffset = 120.0;
    const double baseBubbleHorizontalPadding = 20.0;
    const double baseBubbleHeight = 80.0;
    // ⭐ 吹き出し内の基準フォントサイズをさらに小さく調整
    const double baseBubbleFontSize = 22.0;
    // ⭐ フォントサイズの上限値をさらに引き下げ
    const double maxBubbleFontSize = 25.0;

    // 撮影エリアの白枠関連
    const double frameWidthRatio = 0.85; // 画面幅に対する比率
    const double frameHeightRatio = 0.4; // 画面高さに対する比率
    const double baseFrameBorderWidth = 6.0;
    const double baseFrameTopMargin = 50.0;

    // シャッターボタン関連
    const double baseShutterButtonBottomOffset = 40.0; // デバイス画面下端からの基準オフセット
    const double baseShutterButtonPadding = 12.0;
    const double baseShutterIconSize = 48.0;

    // 戻るボタン関連
    const double baseBackButtonTopOffset = 10.0;
    const double baseBackButtonRightOffset = 20.0;

    // --- 計算されたUI要素のサイズと位置 ---
    // 吹き出し
    final double bubbleTop =
        screenHeight * (baseBubbleTopOffset / referenceHeight);
    final double bubbleHorizontalPadding =
        screenWidth * (baseBubbleHorizontalPadding / referenceWidth);
    final double bubbleHeight =
        screenHeight * (baseBubbleHeight / referenceHeight);
    final double bubbleFontSize =
        (baseBubbleFontSize * (screenWidth / referenceWidth)).clamp(
          14.0,
          maxBubbleFontSize,
        ) *
        textScaleFactor; // ⭐ 最小値も調整

    // 撮影エリアの白枠
    final double frameWidth = screenWidth * frameWidthRatio;
    final double frameHeight = screenHeight * frameHeightRatio;
    final double frameBorderWidth =
        (baseFrameBorderWidth * (screenWidth / referenceWidth)).clamp(2.0, 8.0);
    final double frameTopMargin =
        screenHeight * (baseFrameTopMargin / referenceHeight);

    // シャッターボタン
    final double shutterButtonBottom =
        (screenHeight * (baseShutterButtonBottomOffset / referenceHeight)) +
        safeAreaPadding.bottom;
    final double shutterButtonPadding = (baseShutterButtonPadding *
            (screenWidth / referenceWidth))
        .clamp(8.0, 20.0);
    final double shutterIconSize = (baseShutterIconSize *
            (screenWidth / referenceWidth))
        .clamp(36.0, 60.0);

    // 戻るボタン
    final double backButtonTop =
        (screenHeight * (baseBackButtonTopOffset / referenceHeight)) +
        safeAreaPadding.top;
    final double backButtonRight =
        screenWidth * (baseBackButtonRightOffset / referenceWidth);

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller.value.isInitialized) {
              return Stack(
                children: [
                  // カメラプレビュー（背景）
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),

                  // 上部の吹き出しとテキスト
                  Positioned(
                    top: bubbleTop,
                    left: bubbleHorizontalPadding,
                    right: bubbleHorizontalPadding,
                    height: bubbleHeight,
                    child: Bubble(
                      text: 'とりたいものを ここにいれてね！',
                      textStyle: TextStyle(
                        fontSize: bubbleFontSize, // ⭐ 調整されたフォントサイズを使用
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),

                  // 撮影エリアの白枠
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: frameTopMargin),
                      width: frameWidth,
                      height: frameHeight,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: frameBorderWidth,
                        ),
                      ),
                    ),
                  ),

                  // カメラと画像ボタン
                  Positioned(
                    bottom: shutterButtonBottom,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ScaleTransition(
                        scale: _shutterButtonScaleAnimation,
                        child: GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            padding: EdgeInsets.all(shutterButtonPadding),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              size: shutterIconSize,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 戻るボタン
                  Positioned(
                    top: backButtonTop,
                    right: backButtonRight,
                    child: CustomBackButton(),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
