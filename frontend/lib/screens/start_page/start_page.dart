// lib/widgets/header.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/select_target/select_target_screen.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Positioned.fill(
            child: Image.asset('images/start.png', fit: BoxFit.cover),
          ),

          // コンテンツ
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アプリロゴ
                Image.asset('images/logo.png', width: 470),
                const SizedBox(height: 90),
                // スタートボタン（テキストのみ）
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      // 角丸のボタン
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 136, 89, 2),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 25,
                    ),
                    elevation: 15,
                    shadowColor: const Color.fromARGB(
                      255,
                      62,
                      34,
                      0,
                    ).withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectTargetScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "はじめる",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
