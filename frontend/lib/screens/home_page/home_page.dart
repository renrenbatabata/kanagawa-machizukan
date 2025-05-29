// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/ad_banner.dart';
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
                  const DailyQuizCard(),
                  const SizedBox(height: 16),

                  const KanagawaLoveArea(),
                  const AdBanner(
                    adUnitId:
                        'ca-app-pub-3940256099942544/6300978111', // ホーム画面用のテストID
                  ),
                  const SizedBox(height: 10),
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
