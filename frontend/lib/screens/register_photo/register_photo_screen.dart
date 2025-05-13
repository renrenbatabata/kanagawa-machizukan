import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:frontend/widgets/control.dart';

class PicturePreviewScreen extends StatelessWidget {
  final String imagePath;

  const PicturePreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ヘッダー部分
          const ImageHeader(),

          // 再撮影ボタン
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 20,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.close, color: Colors.white, size: 30),
                  SizedBox(width: 2),
                  Text(
                    "とりなおす",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 画像表示部分
          Expanded(
            child: Center(
              child: ClipOval(
                child: Image.file(
                  File(imagePath),
                  width: 350,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 登録エリア
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Bubble(
                  text: 'ずかんにとうろくしてね！',
                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 20,
                    ),
                  ),
                  onPressed: () {
                    // 登録ボタン押下時の処理
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                  label: const Text(
                    "とうろく",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      // Controlウィジェットを下部ナビゲーションに固定
      bottomNavigationBar: Control(),
    );
  }
}
