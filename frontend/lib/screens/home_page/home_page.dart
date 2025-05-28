// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/screens/home_page/kanagawa_love_area.dart';
import 'package:frontend/screens/home_page/daily_quiz_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
