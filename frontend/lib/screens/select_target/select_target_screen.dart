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
    // デバイスの画面サイズ情報を取得
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor; // テキストのスケールファクターも取得

    // --- 調整可能な基準値 ---
    // 一般的なスマートフォン（例: iPhone 8/SE, Galaxy S9など）の幅と高さを基準とします。
    // これらの値を変更することで、全てのUI要素の基準サイズを一括で調整できます。
    const double referenceScreenWidth = 375.0; // iPhone 8/SE などの幅
    const double referenceScreenHeight = 667.0; // iPhone 8/SE などの高さ

    // フォントサイズとパディングの基準値を設定
    const double baseTitleFontSize = 28.0; // タイトルの初期サイズを少し小さくしました
    const double baseButtonFontSize = 24.0; // ボタンの初期サイズを少し小さくしました
    const double baseButtonVerticalPadding = 18.0; // ボタンの垂直パディングを少し調整
    const double baseVerticalSpacing = 30.0; // ボタン間のスペースの基準値

    // --- 画面サイズとテキストスケールファクターに基づいてフォントサイズを調整 ---
    // 画面幅と高さの比率を考慮して、より柔軟にスケーリング
    // clamp()の最大値と最小値を調整することで、文字サイズが極端に大きく/小さくなるのを防ぎます
    final double adjustedTitleFontSize =
        (baseTitleFontSize * (screenWidth / referenceScreenWidth)).clamp(
          baseTitleFontSize * 0.8,
          baseTitleFontSize * 1.5,
        ) *
        textScaleFactor;
    final double adjustedButtonFontSize =
        (baseButtonFontSize * (screenWidth / referenceScreenWidth)).clamp(
          baseButtonFontSize * 0.8,
          baseButtonFontSize * 1.3,
        ) *
        textScaleFactor;
    final double adjustedButtonPaddingVertical = (baseButtonVerticalPadding *
            (screenHeight / referenceScreenHeight))
        .clamp(
          baseButtonVerticalPadding * 0.8,
          baseButtonVerticalPadding * 1.5,
        );
    final double adjustedVerticalSpacing = (baseVerticalSpacing *
            (screenHeight / referenceScreenHeight))
        .clamp(baseVerticalSpacing * 0.8, baseVerticalSpacing * 1.5);

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
                    SizedBox(height: screenHeight * 0.015), // 高さを画面高さの割合で調整
                    Center(
                      child: Text(
                        'しゃしん を とりたいのを\nえらぼう！',
                        style: TextStyle(
                          fontSize: adjustedTitleFontSize, // 動的に調整されたフォントサイズ
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center, // 中央寄せにすると改行時に見やすい
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05), // 高さを画面高さの割合で調整
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
                      fontSize: adjustedButtonFontSize,
                      verticalPadding: adjustedButtonPaddingVertical,
                    ),
                    SizedBox(height: adjustedVerticalSpacing), // 調整された縦の間隔を使用
                    _TargetButton(
                      icon: Icons.temple_buddhist,
                      label: 'れきし',
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
                      fontSize: adjustedButtonFontSize,
                      verticalPadding: adjustedButtonPaddingVertical,
                    ),
                    SizedBox(height: adjustedVerticalSpacing), // 調整された縦の間隔を使用
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
                      fontSize: adjustedButtonFontSize,
                      verticalPadding: adjustedButtonPaddingVertical,
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
  final double fontSize;
  final double verticalPadding;

  const _TargetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.fontSize,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        // アイコンサイズもフォントサイズに合わせて調整
        icon: Icon(
          icon,
          color: Colors.white,
          size: fontSize * 1.2,
        ), // アイコンサイズを少し大きくしました
        label: Text(
          label,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ),
      ),
    );
  }
}
