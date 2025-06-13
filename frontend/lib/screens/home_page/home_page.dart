// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/ad_banner.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/screens/home_page/kanagawa_love_area.dart';
import 'package:frontend/screens/home_page/daily_quiz_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/x_official_notice_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? admobId = dotenv.env['ADMOB_BANNER_ID'];
    if (admobId == null) {
      print('❌ ADMOB_BANNER_IDが設定されていません。');
    } else {
      print('✅ ADMOB_BANNER_ID: $admobId');
    }
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
                  // ここにSizedBoxを追加して高さを指定
                  SizedBox(height: 750, child: const XOfficialNoticeScreen()),
                  const SizedBox(height: 16),

                  const KanagawaLoveArea(),
                  AdBanner(
                    adUnitId: admobId!, // ホーム画面用のテストID
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
