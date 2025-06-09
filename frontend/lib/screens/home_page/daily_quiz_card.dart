// lib/widgets/daily_quiz_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // QuizQuestionモデルをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsとColorExtensionをインポート
import 'package:frontend/screens/quiz_page/quiz_screen.dart'; // QuizScreenをインポート
import 'dart:math'; // Randomクラスを使用するためにインポート
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'dart:convert'; // JSONデコード用
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ホーム画面に表示する簡易クイズカード
class DailyQuizCard extends StatefulWidget {
  const DailyQuizCard({super.key});

  @override
  State<DailyQuizCard> createState() => _DailyQuizCardState();
}

class _DailyQuizCardState extends State<DailyQuizCard> {
  //  データの状態管理変数
  QuizQuestion? _dailyQuestion; // その日のクイズ問題（Nullableにする）
  bool _isLoading = true; // データのロード中かどうかのフラグ
  String? _errorMessage; // エラーメッセージ

  int? _selectedOptionIndex; // 選択された選択肢のインデックス
  bool _isAnswerChecked = false; // 回答がチェックされたかどうかのフラグ

  // エラーダイアログを表示するメソッドを追加
  Future<void> _showErrorDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetDailyQuiz(); // 画面が初期化されるときにその日のクイズを生成
  }

  // ★★★  バックエンドからクイズ問題を取得し、日替わりクイズをセットする関数 ★★★
  Future<void> _fetchAndSetDailyQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      _showErrorDialog(context, "APIのURLが設定されていません。");
      return;
    }
    final uri = Uri.parse('$baseUrl/quiz'); // APIのエンドポイント

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        if (jsonList.isEmpty) {
          _errorMessage = 'クイズ問題がありません。';
          _dailyQuestion = null;
          return;
        }
        final List<QuizQuestion> allQuizQuestions =
            jsonList.map((json) => QuizQuestion.fromJson(json)).toList();

        // その日のクイズ問題を生成
        final int todaySeed =
            DateTime.now().day +
            DateTime.now().month * 100 +
            DateTime.now().year * 10000;
        final Random random = Random(todaySeed);

        // allQuizQuestionsをシャッフル
        final List<QuizQuestion> shuffledQuestions = List.from(
          allQuizQuestions,
        );
        shuffledQuestions.shuffle(random);

        // その日の問題を選ぶ（1問だけ）
        _dailyQuestion = shuffledQuestions.first;
      } else {
        _errorMessage = 'クイズの取得に失敗しました: ${response.statusCode}';
        debugPrint('DailyQuizCard APIエラー: ${response.body}');
        _dailyQuestion = null;
      }
    } catch (e) {
      _errorMessage = 'ネットワークエラー: $e';
      debugPrint('DailyQuizCard 通信エラー: $e');
      _dailyQuestion = null;
    } finally {
      setState(() {
        _isLoading = false;
        _selectedOptionIndex = null; // 新しい問題がセットされたら選択肢をリセット
        _isAnswerChecked = false; // 回答済みフラグをリセット
      });
    }
  }

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
    if (_isLoading) {
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

    if (_errorMessage != null || _dailyQuestion == null) {
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
              _errorMessage ?? '今日のクイズは表示できませんでした。\n後でもう一度お試しください。',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _fetchAndSetDailyQuiz,
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
            _dailyQuestion!.questionText, // Nullable対応
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
                                _dailyQuestion!.correctOptionIndex
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
                              _dailyQuestion!.correctOptionIndex
                          ? 'せいかい！'
                          : 'ざんねん！')
                      : 'こたえをえらんでね！',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _isAnswerChecked
                            ? (_selectedOptionIndex ==
                                    _dailyQuestion!.correctOptionIndex
                                ? AppColors.correctAnswerGreen.darker()
                                : AppColors.wrongAnswerRed.darker())
                            : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon:
                    _isAnswerChecked
                        ? (_selectedOptionIndex ==
                                _dailyQuestion!.correctOptionIndex
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
                    _dailyQuestion!.options.asMap().entries.map((entry) {
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
                                            _dailyQuestion!.correctOptionIndex
                                    ? AppColors.correctAnswerGreen.darker()
                                    : _isAnswerChecked &&
                                        idx == _selectedOptionIndex &&
                                        idx !=
                                            _dailyQuestion!.correctOptionIndex
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
                        _dailyQuestion!.correctOptionIndex ==
                                _selectedOptionIndex
                            ? AppColors.correctAnswerGreen.withOpacity(0.1)
                            : AppColors.wrongAnswerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _dailyQuestion!.correctOptionIndex ==
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
                        _dailyQuestion!.correctOptionIndex ==
                                _selectedOptionIndex
                            ? 'せいかい！'
                            : 'ざんねん...',
                        style: TextStyle(
                          fontSize: 16, // フォントサイズを調整
                          fontWeight: FontWeight.bold,
                          color:
                              _dailyQuestion!.correctOptionIndex ==
                                      _selectedOptionIndex
                                  ? AppColors.correctAnswerGreen
                                  : AppColors.wrongAnswerRed,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _dailyQuestion!.explanation,
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
