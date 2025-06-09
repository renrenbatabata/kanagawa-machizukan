// lib/screens/quiz_page/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/widgets/ad_banner.dart';
import 'package:frontend/widgets/header.dart'; // ImageHeaderをインポート
import 'package:frontend/widgets/control.dart'; // Controlをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート (ColorExtensionもここから利用されます)
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // QuizQuestionモデルをインポート
import 'dart:math'; // Randomクラスを使用するためにインポート
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'dart:convert'; // JSONデコード用
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // ★★★ 修正点: データの状態管理変数 ★★★
  List<QuizQuestion>? _allQuizQuestions; // バックエンドから取得した全クイズ問題
  List<QuizQuestion> _dailyQuizQuestions = []; // その日のクイズ問題リスト

  // ★★★ 修正点: ローディングとエラーの状態管理 ★★★
  bool _isLoading = true; // データのロード中かどうかのフラグ
  String? _errorMessage; // エラーメッセージ

  int _currentQuestionIndex = 0; // 現在の問題のインデックス
  int? _selectedOptionIndex; // 選択された選択肢のインデックス
  bool _isAnswerChecked = false; // 回答がチェックされたかどうかのフラグ
  int _score = 0; // スコア
  bool _quizFinished = false; // クイズが終了したかどうかのフラグ

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions(); // 画面が初期化されるときにJava APIからクイズデータを取得
  }

  // ★★★ 追加: Java バックエンドからクイズ問題を取得する関数 ★★★
  Future<void> _fetchQuizQuestions() async {
    // ★★★ JavaバックエンドのクイズAPIエンドポイントに置き換える ★★★
    // 例: http://10.17.6.221:8080/api/quizzes
    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'APIのURLが設定されていません。';
      });
      return;
    }
    final uri = Uri.parse('$baseUrl/quiz'); // APIのエンドポイント

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _allQuizQuestions =
            jsonList.map((json) => QuizQuestion.fromJson(json)).toList();
        _generateDailyQuiz(); // 取得したデータでその日のクイズを生成
      } else {
        _errorMessage = 'クイズの取得に失敗しました: ${response.statusCode}';
        debugPrint('クイズAPIエラーレスポンス: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'ネットワークエラー: $e';
      debugPrint('クイズAPI通信エラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // lib/screens/quiz_page/quiz_screen.dart の _QuizScreenState クラス内

  // その日のクイズ問題を生成する関数 (バックエンドから取得した全問題を使用)
  void _generateDailyQuiz() {
    // ★★★ 修正点: _allQuizQuestions がnullまたは空の場合は処理をスキップ ★★★
    if (_allQuizQuestions == null || _allQuizQuestions!.isEmpty) {
      _dailyQuizQuestions = [];
      _quizFinished = true; // 問題がないのでクイズを終了状態にする
      return;
    }

    final int todaySeed =
        DateTime.now().day +
        DateTime.now().month * 100 +
        DateTime.now().year * 10000;
    final Random random = Random(todaySeed);

    // ★★★ 修正点: _allQuizQuestions からシャッフルして問題を選択 ★★★
    final List<QuizQuestion> shuffledQuestions = List.from(
      _allQuizQuestions!,
    ); // ここを修正
    shuffledQuestions.shuffle(random);

    _dailyQuizQuestions = shuffledQuestions.take(5).toList(); // 最大5問に制限

    // 状態をリセット
    _currentQuestionIndex = 0;
    _selectedOptionIndex = null;
    _isAnswerChecked = false;
    _score = 0;
    _quizFinished = false; // クイズが新しく始まるのでfalse
  }

  // ★★★ 追加: 回答をチェックし、次の問題へ進む、またはクイズを終了する関数 ★★★
  void _checkAnswerAndProceed() {
    setState(() {
      _isAnswerChecked = true; // 回答チェック済みフラグを立てる

      // 正解かどうかの判定
      if (_selectedOptionIndex ==
          _dailyQuizQuestions[_currentQuestionIndex].correctOptionIndex) {
        _score++;
      }
    });

    // 解説表示後、少し遅延させてから次の問題へ自動で進む (または手動ボタン)
    Future.delayed(const Duration(seconds: 60), () {
      // 2秒後に自動で次へ
      if (!mounted) return; // ウィジェットがツリーに存在しない場合は何もしない

      setState(() {
        if (_currentQuestionIndex < _dailyQuizQuestions.length - 1) {
          _currentQuestionIndex++;
          _selectedOptionIndex = null; // 選択肢をリセット
          _isAnswerChecked = false; // 回答チェック済みフラグをリセット
        } else {
          _quizFinished = true; // クイズ終了
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? admobId = dotenv.env['ADMOB_BANNER_ID'];
    if (admobId == null) {
      print('❌ ADMOB_BANNER_IDが設定されていません。');
    } else {
      print('✅ ADMOB_BANNER_ID: $admobId');
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // ★★★ 修正: ローディング中、エラー時、問題がない場合の表示ロジック ★★★
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6E5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('クイズ問題を読み込み中...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6E5),
        appBar: AppBar(
          title: const Text('エラー'),
          backgroundColor: AppColors.mainGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _fetchQuizQuestions, // リトライボタン
                  child: const Text('もう一度読み込む'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ここは `_dailyQuizQuestions` が空の場合の処理
    // _allQuizQuestionsが空の場合も、ここで処理されるべき
    if (_dailyQuizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6E5),
        appBar: AppBar(
          title: const Text('クイズなし'),
          backgroundColor: AppColors.mainGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '本日のクイズ問題がありません。\n後でもう一度お試しください。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _fetchQuizQuestions,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

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
          const ImageHeader(),
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
                        buttonColor = AppColors.correctAnswerGreen;
                        textColor = Colors.white;
                      } else if (isSelected) {
                        buttonColor = AppColors.wrongAnswerRed;
                        textColor = Colors.white;
                      } else {
                        buttonColor = Colors.grey.shade300;
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
                                ? null
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
                                      ? AppColors.correctAnswerGreen.darker()
                                      : _isAnswerChecked &&
                                          isSelected &&
                                          !isCorrect
                                      ? AppColors.wrongAnswerRed.darker()
                                      : Colors.grey.shade400,
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
                              ? null
                              : _checkAnswerAndProceed,
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

                  // 解説表示
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
                                    )
                                    : AppColors.wrongAnswerRed.withOpacity(0.1),
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
                                  fontSize: 16,
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

          // 広告バナー
          AdBanner(
            adUnitId: admobId!, // ホーム画面用のテストID
          ),
          const Control(), // 共通フッター
        ],
      ),
    );
  }
}
