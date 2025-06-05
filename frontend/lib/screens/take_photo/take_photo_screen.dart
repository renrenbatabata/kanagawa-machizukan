import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/analysis_page/analysis.dart';
import 'package:frontend/widgets/back_button.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 位置情報サービスが有効か確認
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('位置情報サービスが無効です。');
    return Future.error('位置情報サービスが無効です。');
  }

  // 権限を確認
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

  // 現在地を取得
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

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
                  child:
                  // 撮影ボタン
                  GestureDetector(
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
