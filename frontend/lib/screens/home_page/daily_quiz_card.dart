// lib/widgets/daily_quiz_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // quizQuestionsをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート
import 'package:frontend/screens/quiz_page/quiz_screen.dart'; // QuizScreenをインポート

// ColorExtensionはquiz_screen.dartまたはcolors.dartに置くのが理想ですが、
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
      padding: const EdgeInsets.all(12), // 全体のパディングをさらに小さく
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 252, 245),
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
              fontSize: 20, // タイトルフォントをさらに小さく
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 10), // スペースを調整
          Text(
            _dailyQuestion.questionText, // 今日の問題文
            style: const TextStyle(
              fontSize: 16, // フォントを小さく
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 15), // スペースを調整
          // プルダウン形式の選択肢
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color:
                  _isAnswerChecked
                      ? Colors.grey.shade200
                      : Colors.white, // 回答後は背景をグレーに
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _isAnswerChecked
                        ? (_selectedOptionIndex ==
                                _dailyQuestion.correctOptionIndex
                            ? AppColors.correctAnswerGreen
                            : AppColors.wrongAnswerRed)
                        : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              // 下線非表示
              child: DropdownButton<int>(
                value: _selectedOptionIndex,
                isExpanded: true, // 幅いっぱいに広げる
                hint: Text(
                  _isAnswerChecked
                      ? (_selectedOptionIndex ==
                              _dailyQuestion.correctOptionIndex
                          ? 'せいかい！'
                          : 'ざんねん！')
                      : 'こたえをえらんでね！', // ヒントテキスト
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _isAnswerChecked
                            ? (_selectedOptionIndex ==
                                    _dailyQuestion.correctOptionIndex
                                ? AppColors.correctAnswerGreen.darker()
                                : AppColors.wrongAnswerRed.darker())
                            : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon:
                    _isAnswerChecked
                        ? (_selectedOptionIndex ==
                                _dailyQuestion.correctOptionIndex
                            ? Icon(
                              Icons.check_circle,
                              color: AppColors.correctAnswerGreen,
                            )
                            : Icon(
                              Icons.cancel,
                              color: AppColors.wrongAnswerRed,
                            ))
                        : const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ), // 通常のアイコン
                onChanged:
                    _isAnswerChecked
                        ? null // 回答チェック済みの場合は無効化
                        : (int? newValue) {
                          setState(() {
                            _selectedOptionIndex = newValue;
                          });
                        },
                items:
                    _dailyQuestion.options.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String option = entry.value;
                      return DropdownMenuItem<int>(
                        value: idx,
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _isAnswerChecked &&
                                        idx == _dailyQuestion.correctOptionIndex
                                    ? AppColors.correctAnswerGreen.darker()
                                    : _isAnswerChecked &&
                                        idx == _selectedOptionIndex &&
                                        idx != _dailyQuestion.correctOptionIndex
                                    ? AppColors.wrongAnswerRed.darker()
                                    : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                dropdownColor: Colors.white, // ドロップダウンリストの背景色
              ),
            ),
          ),
          const SizedBox(height: 15),

          // 回答チェックまたは解説表示
          if (!_isAnswerChecked)
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    _selectedOptionIndex == null
                        ? null
                        : () {
                          setState(() {
                            _isAnswerChecked = true;
                            // ここでラブ度やスコアの更新ロジックを追加できます
                            // 例: if (_selectedOptionIndex == _dailyQuestion.correctOptionIndex) { ラブ度アップの処理 }
                          });
                        },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('こたえをみる！'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedOptionIndex == null
                          ? Colors.grey
                          : AppColors.mainGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            )
          else // 回答チェック済みの場合
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _dailyQuestion.correctOptionIndex ==
                                _selectedOptionIndex
                            ? AppColors.correctAnswerGreen.withOpacity(0.1)
                            : AppColors.wrongAnswerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _dailyQuestion.correctOptionIndex ==
                                      _selectedOptionIndex
                                  ? AppColors.correctAnswerGreen
                                  : AppColors.wrongAnswerRed,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _dailyQuestion.explanation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          // 「もっとクイズに挑戦する」ボタンは常に表示（クイズカードの一部として）
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
              icon: const Icon(Icons.quiz_outlined, size: 18),
              label: const Text('もっとクイズにちょうせん！'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
