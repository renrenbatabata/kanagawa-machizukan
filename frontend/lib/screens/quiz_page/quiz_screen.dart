// lib/screens/quiz_page/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/widgets/header.dart'; // ImageHeaderをインポート
import 'package:frontend/widgets/control.dart'; // Controlをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート (ColorExtensionもここから利用されます)
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // quizQuestionsをインポート
import 'dart:math'; // Randomクラスを使用するためにインポート

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _dailyQuizQuestions = []; // その日のクイズ問題リスト
  int _currentQuestionIndex = 0; // 現在の問題のインデックス
  int? _selectedOptionIndex; // 選択された選択肢のインデックス
  bool _isAnswerChecked = false; // 回答がチェックされたかどうかのフラグ
  int _score = 0; // スコア
  bool _quizFinished = false; // クイズが終了したかどうかのフラグ

  @override
  void initState() {
    super.initState();
    _generateDailyQuiz(); // 画面が初期化されるときにその日のクイズを生成
  }

  // その日のクイズ問題を生成する関数
  void _generateDailyQuiz() {
    final int todaySeed =
        DateTime.now().day +
        DateTime.now().month * 100 +
        DateTime.now().year * 10000;
    final Random random = Random(todaySeed);

    // quizQuestionsをシャッフル
    final List<QuizQuestion> shuffledQuestions = List.from(quizQuestions);
    shuffledQuestions.shuffle(random);

    // 最大5問に制限
    _dailyQuizQuestions = shuffledQuestions.take(5).toList();

    // 状態をリセット
    _currentQuestionIndex = 0;
    _selectedOptionIndex = null;
    _isAnswerChecked = false;
    _score = 0;
    _quizFinished = false;
  }

  @override
  Widget build(BuildContext context) {
    // クイズが終了した場合
    if (_quizFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6E5),
        appBar: AppBar(
          title: const Text('クイズおわり！'),
          backgroundColor: AppColors.mainGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'クイズおわり！\n${_dailyQuizQuestions.length}問中 $_score問せいかい！',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _generateDailyQuiz(); // 新しいクイズを生成してリセット
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('もういちどちょうせん！'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // ホーム画面に戻る
                },
                icon: const Icon(Icons.home),
                label: const Text('ホームにもどる'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 現在の問題
    final QuizQuestion currentQuestion =
        _dailyQuizQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),
      body: Column(
        children: [
          const ImageHeader(), // 共通ヘッダー
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // クイズの進捗表示
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_currentQuestionIndex + 1} / ${_dailyQuizQuestions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 問題文
                  Container(
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
                    child: Text(
                      currentQuestion.questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 選択肢
                  ...List.generate(currentQuestion.options.length, (index) {
                    final bool isCorrect =
                        index == currentQuestion.correctOptionIndex;
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
                          isSelected
                              ? AppColors.selectedOptionBlue
                              : Colors.white;
                      textColor = isSelected ? Colors.white : Colors.black87;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            vertical: 18,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  _isAnswerChecked && isCorrect
                                      ? AppColors.correctAnswerGreen
                                          .darker() // 正解の場合は濃い緑のボーダー
                                      : _isAnswerChecked &&
                                          isSelected &&
                                          !isCorrect
                                      ? AppColors.wrongAnswerRed
                                          .darker() // 不正解の場合は濃い赤のボーダー
                                      : Colors.grey.shade400, // 通常は薄いグレー
                              width: 2,
                            ),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          currentQuestion.options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),

                  // 回答チェックボタン
                  if (!_isAnswerChecked)
                    ElevatedButton.icon(
                      onPressed:
                          _selectedOptionIndex == null
                              ? null // 選択肢が選ばれていない場合は無効
                              : () {
                                setState(() {
                                  _isAnswerChecked = true;
                                  if (_selectedOptionIndex ==
                                      currentQuestion.correctOptionIndex) {
                                    _score++;
                                  }
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
                          horizontal: 25,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),

                  // 解説と次へボタン
                  if (_isAnswerChecked)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color:
                                currentQuestion.correctOptionIndex ==
                                        _selectedOptionIndex
                                    ? AppColors.correctAnswerGreen.withOpacity(
                                      0.1,
                                    ) // 正解時は薄い緑
                                    : AppColors.wrongAnswerRed.withOpacity(
                                      0.1,
                                    ), // 不正解時は薄い赤
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  currentQuestion.correctOptionIndex ==
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
                                currentQuestion.correctOptionIndex ==
                                        _selectedOptionIndex
                                    ? 'せいかい！'
                                    : 'ざんねん...',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      currentQuestion.correctOptionIndex ==
                                              _selectedOptionIndex
                                          ? AppColors.correctAnswerGreen
                                          : AppColors.wrongAnswerRed,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                currentQuestion.explanation,
                                style: const TextStyle(
                                  fontSize: 16, // 解説のフォントサイズを調整
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          // 次へボタンを中央寄せ
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                if (_currentQuestionIndex <
                                    _dailyQuizQuestions.length - 1) {
                                  _currentQuestionIndex++;
                                  _selectedOptionIndex = null;
                                  _isAnswerChecked = false;
                                } else {
                                  _quizFinished = true; // クイズ終了
                                }
                              });
                            },
                            icon: Icon(
                              _currentQuestionIndex <
                                      _dailyQuizQuestions.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.done_all,
                            ),
                            label: Text(
                              _currentQuestionIndex <
                                      _dailyQuizQuestions.length - 1
                                  ? 'つぎのもんだいへ！'
                                  : 'クイズおわり！',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 15,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const Control(), // 共通フッター
        ],
      ),
    );
  }
}
