// lib/widgets/daily_quiz_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // QuizQuestionモデルをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsとColorExtensionをインポート
import 'package:frontend/screens/quiz_page/quiz_screen.dart'; // QuizScreenをインポート
// import 'dart:math'; // Randomクラスは不要になる
// import 'package:http/http.dart' as http; // HTTPリクエストは不要になる
// import 'dart:convert'; // JSONデコードは不要になる
// import 'package:flutter_dotenv/flutter_dotenv'; // dotenvも不要になる

// ホーム画面に表示する簡易クイズカード
class DailyQuizCard extends StatefulWidget {
  // ★追加・変更: 親からデータを受け取る
  final QuizQuestion? dailyQuestion;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry; // 再試行ボタン用のコールバック

  const DailyQuizCard({
    super.key,
    required this.dailyQuestion, // 必須プロパティに
    required this.isLoading, // 必須プロパティに
    this.errorMessage, // エラーメッセージはNullable
    this.onRetry, // 再試行コールバックもNullable
  });

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  // データの状態管理変数は親から受け取るため、ここでは回答選択の状態のみ
  int? _selectedOptionIndex; // 選択された選択肢のインデックス
  bool _isAnswerChecked = false; // 回答がチェックされたかどうかのフラグ

  // エラーダイアログは不要になる (HomePageで処理するため)
  // Future<void> _showErrorDialog(BuildContext context, String message) async { ... }

  @override
  void initState() {
    super.initState();
    // ここで_fetchAndSetDailyQuiz()は呼ばない
  }

  // 親からデータが更新されたときに状態をリセット
  @override
  void didUpdateWidget(covariant DailyQuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 新しいクイズ問題が来た場合、選択状態をリセット
    if (widget.dailyQuestion != oldWidget.dailyQuestion) {
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
    }
  }

  // ★★★ バックエンドからクイズ問題を取得し、日替わりクイズをセットする関数は親に移動 ★★★
  // この関数は削除されます。

  // 回答をチェックする関数 (変更なし)
  void _checkAnswer() {
    setState(() {
      _isAnswerChecked = true;
      // ここでラブ度やスコアの更新ロジックを追加できます
      // 例: if (_selectedOptionIndex == _dailyQuestion?.correctOptionIndex) { ラブ度アップの処理 }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ロード中
    if (widget.isLoading) {
      // 親から受け取ったisLoadingを使用
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // エラーまたはデータがない場合
    if (widget.errorMessage != null || widget.dailyQuestion == null) {
      // 親から受け取った errorMessage & dailyQuestion
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.sentiment_dissatisfied,
              color: Colors.grey,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              widget.errorMessage ?? '今日のクイズは表示できませんでした。\n後でもう一度お試しください。',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: widget.onRetry, // 親から渡されたコールバックを使用
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // クイズ表示部分
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 252, 245),
        borderRadius: BorderRadius.circular(15),
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
            '💡今日のかながわくクイズ',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.dailyQuestion!.questionText, // 親から受け取ったdailyQuestionを使用
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 15),
          // プルダウン形式の選択肢
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: _isAnswerChecked ? Colors.grey.shade200 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _isAnswerChecked
                        ? (_selectedOptionIndex ==
                                widget.dailyQuestion!.correctOptionIndex
                            ? AppColors.correctAnswerGreen
                            : AppColors.wrongAnswerRed)
                        : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedOptionIndex,
                isExpanded: true,
                hint: Text(
                  _isAnswerChecked
                      ? (_selectedOptionIndex ==
                              widget.dailyQuestion!.correctOptionIndex
                          ? 'せいかい！'
                          : 'ざんねん！')
                      : 'こたえをえらんでね！',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _isAnswerChecked
                            ? (_selectedOptionIndex ==
                                    widget.dailyQuestion!.correctOptionIndex
                                ? AppColors.correctAnswerGreen.darker()
                                : AppColors.wrongAnswerRed.darker())
                            : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon:
                    _isAnswerChecked
                        ? (_selectedOptionIndex ==
                                widget.dailyQuestion!.correctOptionIndex
                            ? const Icon(
                              Icons.check_circle,
                              color: AppColors.correctAnswerGreen,
                            )
                            : const Icon(
                              Icons.cancel,
                              color: AppColors.wrongAnswerRed,
                            ))
                        : const Icon(Icons.arrow_drop_down, color: Colors.grey),
                onChanged:
                    _isAnswerChecked
                        ? null
                        : (int? newValue) {
                          setState(() {
                            _selectedOptionIndex = newValue;
                          });
                        },
                items:
                    widget.dailyQuestion!.options.asMap().entries.map((entry) {
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
                                        idx ==
                                            widget
                                                .dailyQuestion!
                                                .correctOptionIndex
                                    ? AppColors.correctAnswerGreen.darker()
                                    : _isAnswerChecked &&
                                        idx == _selectedOptionIndex &&
                                        idx !=
                                            widget
                                                .dailyQuestion!
                                                .correctOptionIndex
                                    ? AppColors.wrongAnswerRed.darker()
                                    : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                dropdownColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // 回答チェックボタンまたは解説表示
          if (!_isAnswerChecked)
            Center(
              child: ElevatedButton.icon(
                onPressed: _selectedOptionIndex == null ? null : _checkAnswer,
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
                  elevation: 2,
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
                        widget.dailyQuestion!.correctOptionIndex ==
                                _selectedOptionIndex
                            ? AppColors.correctAnswerGreen.withOpacity(0.1)
                            : AppColors.wrongAnswerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          widget.dailyQuestion!.correctOptionIndex ==
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
                        widget.dailyQuestion!.correctOptionIndex ==
                                _selectedOptionIndex
                            ? 'せいかい！'
                            : 'ざんねん...',
                        style: TextStyle(
                          fontSize: 16, // フォントサイズを調整
                          fontWeight: FontWeight.bold,
                          color:
                              widget.dailyQuestion!.correctOptionIndex ==
                                      _selectedOptionIndex
                                  ? AppColors.correctAnswerGreen
                                  : AppColors.wrongAnswerRed,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.dailyQuestion!.explanation,
                        style: const TextStyle(
                          fontSize: 12, // 解説のフォントサイズを調整
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
