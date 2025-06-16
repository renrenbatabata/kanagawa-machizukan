import 'package:flutter/material.dart';
import 'package:frontend/widgets/ad_banner.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/screens/home_page/kanagawa_love_area.dart'; // KanagawaLoveAreaをインポート
import 'package:frontend/screens/home_page/daily_quiz_card.dart'; // DailyQuizCardのパスを確認
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/widgets/x_official_notice_screen.dart';
import 'package:frontend/screens/post_page/timeline_screen.dart';
import 'package:http/http.dart' as http; // HTTPリクエスト用
import 'dart:convert'; // JSONデコード用
import 'package:frontend/screens/quiz_page/quiz_data.dart'; // QuizQuestionモデルをインポート

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // データの状態管理
  QuizQuestion? _dailyQuestion;
  double? _overallProgressPercent; // ★ 変更: 総合パーセンテージを直接保持
  Map<String, Map<String, int>> _categoryCounts = {}; // ★ 変更: 各カテゴリのカウントを保持
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopPageData(); // 画面初期化時にAPIを叩く
  }

  // エラーダイアログを表示するメソッド
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

  // ★★★ バックエンドから /top エンドポイントのデータを取得する関数 ★★★
  Future<void> _fetchTopPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dailyQuestion = null; // データをリセット
      _overallProgressPercent = null;
      _categoryCounts = {};
    });

    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      setState(() {
        _errorMessage = "APIのURLが設定されていません。";
        _isLoading = false;
      });
      _showErrorDialog(context, "APIのURLが設定されていません。");
      return;
    }
    final uri = Uri.parse('$baseUrl/top'); // /top エンドポイント

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // クイズデータのパース
        final quizJson = responseData['quiz'];
        if (quizJson != null) {
          final QuizQuestion fetchedQuestion = QuizQuestion.fromJson(quizJson);
          // バックエンドが1問返す場合はこれ
          _dailyQuestion = fetchedQuestion;
        } else {
          _errorMessage = (_errorMessage ?? '') + 'クイズデータが見つかりません。';
        }

        // ★ 変更: countデータのパース
        final countData = responseData['count'];
        if (countData != null && countData is Map<String, dynamic>) {
          // 総合パーセンテージ
          final percent = countData['percent'];
          if (percent != null && (percent is double || percent is int)) {
            _overallProgressPercent = (percent as num).toDouble();
          } else {
            _errorMessage =
                (_errorMessage ?? '') + '\n総合パーセンテージデータが見つからないか無効です。';
          }

          // 各カテゴリのカウントデータをマップに格納
          final Map<String, Map<String, int>> tempCategoryCounts = {};
          final List<String> categories = ['turtle', 'flower', 'shrine'];
          for (var category in categories) {
            final categoryMap = countData[category];
            if (categoryMap != null && categoryMap is Map<String, dynamic>) {
              final count = categoryMap['count'];
              final all = categoryMap['all'];
              if (count != null && count is int && all != null && all is int) {
                tempCategoryCounts[category] = {'count': count, 'all': all};
              } else {
                _errorMessage =
                    (_errorMessage ?? '') + '\n$categoryカテゴリのカウントデータが無効です。';
              }
            } else {
              _errorMessage =
                  (_errorMessage ?? '') + '\n$categoryカテゴリデータが見つかりません。';
            }
          }
          _categoryCounts = tempCategoryCounts;
        } else {
          _errorMessage = (_errorMessage ?? '') + '\nカウントデータが見つからないか無効です。';
        }
      } else {
        _errorMessage = 'データの取得に失敗しました: ${response.statusCode}';
        debugPrint('HomePage APIエラー: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'ネットワークエラー: $e';
      debugPrint('HomePage 通信エラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? admobId = dotenv.env['ADMOB_BANNER_ID'];
    if (admobId == null) {
      debugPrint('❌ ADMOB_BANNER_IDが設定されていません。');
    } else {
      debugPrint('✅ ADMOB_BANNER_ID: $admobId');
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
                  // DailyQuizCardにデータを渡す
                  DailyQuizCard(
                    dailyQuestion: _dailyQuestion,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onRetry: _fetchTopPageData, // 再試行ボタンで親の関数を呼ぶ
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // タイムラインが表示される高さを調整
                    child: const TimelineScreen(), // ここにタイムライン画面を配置
                  ),
                  SizedBox(height: 750, child: const XOfficialNoticeScreen()),
                  const SizedBox(height: 16),

                  // ★ KanagawaLoveAreaにデータを渡す
                  KanagawaLoveArea(
                    overallProgressPercent:
                        _overallProgressPercent, // Javaから受け取ったパーセンテージを渡す
                    categoryCounts: _categoryCounts, // 各カテゴリのカウントデータを渡す
                    isLoading: _isLoading, // ラブ度もロード中状態を渡す
                    errorMessage: _errorMessage, // エラーメッセージも渡す
                    onRetry: _fetchTopPageData, // リトライ用コールバック
                  ),
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
