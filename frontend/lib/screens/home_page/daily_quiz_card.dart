// lib/widgets/daily_quiz_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // quizQuestionsをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート
import 'package:frontend/screens/quiz_page/quiz_screen.dart'; // QuizScreenをインポート

// ColorExtensionはquiz_screen.dartまたはcolors.dartに置くのが理想ですが、
// ここに置いておけばこのファイルだけで完結します。
// アプリ全体で使う場合はcolors.dartに移動することをお勧めします。
extension ColorExtension on Color {
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

// ホーム画面に表示する簡易クイズカード
class DailyQuizCard extends StatefulWidget {
  // クラス名を_DailyQuizCardからDailyQuizCardに変更（プライベートでなくなるため）
  const DailyQuizCard({super.key});

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  // 今日表示する問題（ここではシンプルにリストの最初の問題を使用）
  // 実際には日付などに基づいて問題を切り替えるロジックが必要になります
  final QuizQuestion _dailyQuestion = quizQuestions[0];
  int? _selectedOptionIndex; // 選択された選択肢のインデックス
  bool _isAnswerChecked = false; // 回答がチェックされたかどうかのフラグ

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15), // 全体のパディングを少し小さく
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 249, 237),
        borderRadius: BorderRadius.circular(15), // 角を丸くする
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日のかながわくクイズ！！',
            style: TextStyle(
              fontSize: 22, // タイトルフォントを少し小さく
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 15), // スペースを調整
          Text(
            _dailyQuestion.questionText, // 今日の問題文
            style: const TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 0, 0, 0),
            ), // フォントを少し小さく
          ),
          const SizedBox(height: 15), // スペースを調整
          // 選択肢ボタン
          ...List.generate(_dailyQuestion.options.length, (index) {
            final bool isCorrect = index == _dailyQuestion.correctOptionIndex;
            final bool isSelected = index == _selectedOptionIndex;
            Color buttonColor;
            Color textColor;

            if (_isAnswerChecked) {
              if (isCorrect) {
                buttonColor = AppColors.correctAnswerGreen; // 正解色
                textColor = Colors.white;
              } else if (isSelected) {
                buttonColor = AppColors.wrongAnswerRed; // 間違い色
                textColor = Colors.white;
              } else {
                buttonColor = Colors.grey.shade300; // 未選択
                textColor = Colors.black87;
              }
            } else {
              buttonColor =
                  isSelected ? AppColors.selectedOptionBlue : Colors.white;
              textColor = isSelected ? Colors.white : Colors.black87;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
              ), // 垂直方向のパディングを小さく
              child: SizedBox(
                // ボタンの幅を最大にする
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isAnswerChecked
                          ? null // 回答チェック済みの場合はボタンを無効化
                          : () {
                            setState(() {
                              _selectedOptionIndex = index;
                            });
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ), // パディングを小さく
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 角を少し小さく丸める
                      side: BorderSide(
                        color:
                            _isAnswerChecked && isCorrect
                                ? AppColors.correctAnswerGreen
                                    .darker() // 正解の場合は濃い緑のボーダー
                                : _isAnswerChecked && isSelected && !isCorrect
                                ? AppColors.wrongAnswerRed
                                    .darker() // 不正解の場合は濃い赤のボーダー
                                : Colors.grey.shade400, // 通常は薄いグレー
                        width: 2,
                      ),
                    ),
                    elevation: 2,
                    textStyle: TextStyle(
                      fontSize: 16, // フォントを小さく
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  child: Text(
                    _dailyQuestion.options[index],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 15), // スペースを調整
          // 回答チェックまたは解説表示
          if (!_isAnswerChecked)
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    _selectedOptionIndex == null
                        ? null // 選択肢が選ばれていない場合は無効
                        : () {
                          setState(() {
                            _isAnswerChecked = true;
                            // ここでラブ度やスコアの更新ロジックを追加できます
                            // 例: if (_selectedOptionIndex == _dailyQuestion.correctOptionIndex) { ラブ度アップの処理 }
                          });
                        },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('こたえをみる！'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedOptionIndex == null
                          ? Colors.grey
                          : AppColors.mainGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ), // フォントを小さく
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            )
          else // 回答チェック済みの場合
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // パディングを小さく
                  decoration: BoxDecoration(
                    color:
                        _dailyQuestion.correctOptionIndex ==
                                _selectedOptionIndex
                            ? AppColors.correctAnswerGreen.withOpacity(
                              0.1,
                            ) // 正解時は薄い緑
                            : AppColors.wrongAnswerRed.withOpacity(
                              0.1,
                            ), // 不正解時は薄い赤
                    borderRadius: BorderRadius.circular(8), // 角を小さく丸める
                    border: Border.all(
                      color:
                          _dailyQuestion.correctOptionIndex ==
                                  _selectedOptionIndex
                              ? AppColors.correctAnswerGreen
                              : AppColors.wrongAnswerRed,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dailyQuestion.correctOptionIndex ==
                                _selectedOptionIndex
                            ? 'せいかい！'
                            : 'ざんねん...',
                        style: TextStyle(
                          fontSize: 18, // フォントを小さく
                          fontWeight: FontWeight.bold,
                          color:
                              _dailyQuestion.correctOptionIndex ==
                                      _selectedOptionIndex
                                  ? AppColors.correctAnswerGreen
                                  : AppColors.wrongAnswerRed,
                        ),
                      ),
                      const SizedBox(height: 8), // スペースを調整
                      Text(
                        _dailyQuestion.explanation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ), // フォントを小さく
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 15), // スペースを調整
          // もっとクイズに挑戦するボタン
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
              icon: const Icon(Icons.quiz_outlined, size: 20), // アイコンサイズを小さく
              label: const Text('もっとクイズにちょうせん！'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange, // ボタンの色を調整
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ), // パディングを小さく
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ), // フォントを小さく
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
