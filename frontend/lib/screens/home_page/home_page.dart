// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/screens/home_page/kanagawa_love_area.dart';
import 'package:frontend/screens/home_page/daily_quiz_card.dart'; // 新しく作成したDailyQuizCardをインポート

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),

      body: Column(
        children: [
          const ImageHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const DailyQuizCard(), // ここを新しいDailyQuizCardに置き換える
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        "あなたの",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "かながわくラブ度💕",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const KanagawaLoveArea(),
                ],
              ),
            ),
          ),
          const Control(),
        ],
      ),
    );
  }
}

// 元々ここに_DailyQuizCardの定義がありましたが、削除しました。
// _TitleAreaも不要になったため削除しています。
