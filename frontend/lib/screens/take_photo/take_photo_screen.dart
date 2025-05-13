import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/register_photo/register_photo_screen.dart';
import 'package:frontend/widgets/back_button.dart';
import 'package:frontend/widgets/speech_bubble.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key});

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

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PicturePreviewScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
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
                Positioned(
                  top: 40,
                  right: 20,

                  child: CustomBackButton(), // ここで追加
                ),
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
