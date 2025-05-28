import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/take_photo/take_photo_screen.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/back_button.dart';

class SelectTargetScreen extends StatelessWidget {
  const SelectTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4EF),

      body: Column(
        children: [
          const ImageHeader(), // ヘッダー画像
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0, // 左側のパディング
                  right: 10.0, // 右側のパディング
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // もどるボタン
                    const CustomBackButton(),

                    const SizedBox(height: 12),
                    Center(
                      child: const Text(
                        'しゃしん を とりたいのを\nえらぼう！',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    _TargetButton(
                      icon: Icons.local_florist,
                      label: 'おはな　',
                      color: Colors.pinkAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const TakePhotoScreen(category: "flower"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 35),
                    _TargetButton(
                      icon: Icons.temple_buddhist,
                      label: 'じんじゃ',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const TakePhotoScreen(category: "shrine"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 35),
                    _TargetButton(
                      icon: CupertinoIcons.tortoise,
                      label: 'かめ太郎',
                      color: Colors.indigoAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const TakePhotoScreen(category: "turtle"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Control(),
    );
  }
}

// 共通ボタンウィジェット
class _TargetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TargetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        icon: Icon(icon, color: Colors.white, size: 30),
        label: Text(
          label,
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }
}
