import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/result_actions.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String hiraganaName;
  final String description;
  final Map<String, dynamic> originalResultData;
  final String category;
  final String? uuid;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.name,
    required this.hiraganaName,
    required this.description,
    required this.originalResultData,
    required this.category,
    this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy年M月d日').format(DateTime.now());
    print(uuid);

    // デバイスの画面サイズ情報を取得
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor;

    // 基準となる画面サイズを定義 (例: iPhone 8/SEの論理ピクセルサイズ)
    const double referenceWidth = 375.0;
    const double referenceHeight = 667.0;

    // --- 各UI要素のサイズと位置を画面サイズに対する割合で計算 ---

    // タイトルエリアのフォントサイズ
    final double titleFontSize =
        (30.0 * (screenWidth / referenceWidth)).clamp(24.0, 40.0) *
        textScaleFactor;
    final double hiraganaFontSize =
        (18.0 * (screenWidth / referenceWidth)).clamp(15.0, 24.0) *
        textScaleFactor;

    // 写真のサイズ
    // 画面幅の割合で調整。例えば、画面幅の90%を使用
    final double imageSize = (screenWidth * 0.9).clamp(
      280.0,
      400.0,
    ); // 最小280px、最大400px

    // 写真のボーダー幅
    final double imageBorderWidth = (3.0 * (screenWidth / referenceWidth))
        .clamp(2.0, 5.0);

    // 発見日のフォントサイズ
    final double dateFontSize =
        (16.0 * (screenWidth / referenceWidth)).clamp(14.0, 20.0) *
        textScaleFactor;

    // ボタンのパディングとフォントサイズ
    final double buttonHorizontalPadding =
        (30.0 * (screenWidth / referenceWidth)).clamp(20.0, 40.0);
    final double buttonVerticalPadding =
        (12.0 * (screenHeight / referenceHeight)).clamp(10.0, 20.0);
    final double buttonFontSize =
        (20.0 * (screenWidth / referenceWidth)).clamp(18.0, 26.0) *
        textScaleFactor;
    final double buttonIconSize = (24.0 * (screenWidth / referenceWidth)).clamp(
      20.0,
      30.0,
    );

    // 基本データセクションのパディング
    final double dataSectionHorizontalMargin =
        (16.0 * (screenWidth / referenceWidth)).clamp(10.0, 24.0);
    final double dataSectionPadding = (16.0 * (screenWidth / referenceWidth))
        .clamp(12.0, 24.0);

    // 基本データタイトル（きほんデータ）のパディングとフォントサイズ
    final double dataTitleHorizontalPadding =
        (25.0 * (screenWidth / referenceWidth)).clamp(15.0, 35.0);
    final double dataTitleVerticalPadding =
        (8.0 * (screenHeight / referenceHeight)).clamp(6.0, 15.0);
    final double dataTitleFontSize =
        (20.0 * (screenWidth / referenceWidth)).clamp(16.0, 24.0) *
        textScaleFactor;
    final double dataTitleIconSize = (24.0 * (screenWidth / referenceWidth))
        .clamp(20.0, 30.0);

    // 説明文のフォントサイズ
    final double descriptionFontSize =
        (16.0 * (screenWidth / referenceWidth)).clamp(14.0, 20.0) *
        textScaleFactor;

    // 各SizedBoxの高さも画面高さの割合で調整
    final double spacing1 = screenHeight * (30 / referenceHeight);
    final double spacing2 = screenHeight * (8 / referenceHeight);
    final double spacing3 = screenHeight * (16 / referenceHeight);
    final double spacing4 = screenHeight * (24 / referenceHeight);
    final double bottomSpacing =
        screenHeight * (80 / referenceHeight); // フッターの余白

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Column(
        children: [
          ImageHeader(), // ヘッダー画像は変更なし
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: spacing1), // 調整されたSizedBoxの高さ
                  // タイトルエリア
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: dataSectionHorizontalMargin,
                    ),
                    padding: EdgeInsets.all(dataSectionPadding),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF6E5),
                    ), // 背景色
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: titleFontSize, // 動的に調整
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: spacing2), // 調整されたSizedBoxの高さ
                        Text(
                          hiraganaName,
                          style: TextStyle(fontSize: hiraganaFontSize), // 動的に調整
                        ),
                      ],
                    ),
                  ),
                  // 写真
                  Center(
                    child: Container(
                      width: imageSize, // 動的に調整
                      height: imageSize, // 動的に調整
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange,
                          width: imageBorderWidth,
                        ), // ボーダー幅を動的に調整
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.file(
                        File(imagePath),
                        width: imageSize, // 動的に調整
                        height: imageSize, // 動的に調整
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: spacing2), // 調整されたSizedBoxの高さ
                  Text(
                    '発見日: $today',
                    style: TextStyle(fontSize: dateFontSize), // 動的に調整
                  ),
                  SizedBox(height: spacing3), // 調整されたSizedBoxの高さ
                  // しゃしんをほぞんするボタン
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonHorizontalPadding, // 動的に調整
                        vertical: buttonVerticalPadding, // 動的に調整
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // 保存処理を書く
                    },
                    icon: Icon(
                      Icons.download,
                      size: buttonIconSize,
                    ), // アイコンサイズを動的に調整
                    label: Text(
                      "しゃしんをほぞんする",
                      style: TextStyle(fontSize: buttonFontSize), // 動的に調整
                    ),
                  ),
                  SizedBox(height: spacing4), // 調整されたSizedBoxの高さ
                  // きほんデータ
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: dataSectionHorizontalMargin,
                    ),
                    padding: EdgeInsets.all(dataSectionPadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(
                        161,
                        251,
                        215,
                        148,
                      ), // 少し透明感のあるオレンジ
                      border: Border.all(
                        color: Colors.orange,
                        width: imageBorderWidth,
                      ), // ボーダー幅を動的に調整
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: dataTitleHorizontalPadding, // 動的に調整
                              vertical: dataTitleVerticalPadding, // 動的に調整
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                                bottom: Radius.circular(0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.description,
                                  color: Colors.white,
                                  size: dataTitleIconSize,
                                ), // アイコンサイズを動的に調整
                                SizedBox(
                                  width: screenWidth * (4 / referenceWidth),
                                ), // アイコンとテキストの間隔も調整
                                Text(
                                  "きほんデータ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: dataTitleFontSize, // 動的に調整
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: spacing2), // きほんデータタイトルと説明文の間のスペースを調整
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                          ), // 動的に調整
                          textAlign: TextAlign.start, // 説明文は左寄せが自然
                        ),
                      ],
                    ),
                  ),
                  ResultActions(
                    uuid: uuid ?? '',
                    category: category, // カテゴリを指定
                  ),
                  SizedBox(height: bottomSpacing), // フッターの余白
                ],
              ),
            ),
          ),
          // フッター
          const Control(), // Controlウィジェット自体がレスポンシブ対応していると仮定
        ],
      ),
    );
  }
}
