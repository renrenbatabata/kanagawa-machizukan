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
  // ⭐ SingleTickerProviderStateMixin を追加
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // カメラプレビュー（背景）
                Positioned.fill(child: CameraPreview(_controller)),

                // 上部の吹き出しとテキスト
                Positioned(
                  top: 160,
                  left: 20,
                  right: 20,
                  height: 80,
                  child: Bubble(
                    text: 'とりたいものを ここにいれてね！',
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),

                // 撮影エリアの白枠
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                  ),
                ),

                // カメラと画像ボタン
                Positioned(
                  bottom: 150,
                  left: 0,
                  right: 0,
                  child: Center(
                    // Centerウィジェットを追加してボタンを中央に配置
                    // ⭐ ScaleTransition でボタンの拡大縮小アニメーションを適用
                    child: ScaleTransition(
                      scale: _shutterButtonScaleAnimation,
                      child: GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 戻るボタン
                Positioned(top: 40, right: 20, child: CustomBackButton()),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
