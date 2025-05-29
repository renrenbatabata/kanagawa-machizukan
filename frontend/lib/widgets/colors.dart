import 'package:flutter/material.dart';

class AppColors {
  static const Color correctAnswerGreen = Color(0xFF4CAF50); // 緑
  static const Color wrongAnswerRed = Color(0xFFF44336); // 赤
  static const Color selectedOptionBlue = Color(0xFF2196F3); // 青
  static const Color mainGreen = Color(0xFF8BC34A); // メインの緑
  static const Color green = Color(0xFF6BBA79); // 下部ナビゲーションバーの色など
  static const Color greenSub = Color(0xFFB3E0C3); // 薄いグリーン

  static const Color orange = Color(0xFFF9A825); // すべてのメイン
  static const Color orangeSub = Color(0xFFFFCC80); // すべてのサブ

  static const Color pink = Color(0xFFF06292); // おはなのメイン
  static const Color pinkSub = Color(0xFFF8BBD0); // おはなのサブ

  static const Color red = Color(0xFFE53935); // じんじゃのメイン
  static const Color redSub = Color(0xFFFFCDD2); // じんじゃのサブ

  static const Color blue = Color(0xFF2196F3); // かめ太郎のメイン
  static const Color blueSub = Color(0xFFBBDEFB); // かめ太郎のサブ

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

extension ColorExtension on Color {
  /// 現在の色よりも少し暗い色を返します。
  /// 各RGB成分を0.8倍して計算し、0〜255の範囲に収めます。
  Color darker() {
    int r = (red * 0.8).round();
    int g = (green * 0.8).round();
    int b = (blue * 0.8).round();
    return Color.fromARGB(
      alpha,
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }
}
