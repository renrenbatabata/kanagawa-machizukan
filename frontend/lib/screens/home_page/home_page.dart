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
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // データの状態管理
  QuizQuestion? _dailyQuestion;
  // 初期値を設定し、nullの可能性を減らす
  double _overallProgressPercent = 0.0; // デフォルト値を0.0に設定
  Map<String, Map<String, int>> _categoryCounts = {}; // デフォルトで空のマップに設定
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTopPageData(); // 画面初期化時にAPIを叩く
  }

  // ★★★ バックエンドから /top エンドポイントのデータを取得する関数 ★★★
  Future<void> _fetchTopPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _dailyQuestion = null; // データをリセット
      // ここで初期化することで、API失敗時もKanagawaLoveAreaにデフォルト値が渡る
      _overallProgressPercent = 0.0;
      _categoryCounts = {};
    });

    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      setState(() {
        _errorMessage = "APIのURLが設定されていません。";
        _isLoading = false;
      });
      return;
    }

    final String? userId = AuthService().currentUserId;
    if (userId == null) {
      setState(() {
        _errorMessage = "ログインしていません。ログインして図鑑の進捗とクイズを取得しましょう！";
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse(
      '$baseUrl/top',
    ).replace(queryParameters: {'userId': userId});

    try {
      final response = await http.post(uri);

      debugPrint('--- API Response Debug for /top ---');
      debugPrint('Request URL: $uri');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('--- End API Response Debug ---');

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is Map<String, dynamic>) {
          // レスポンスがMapの場合（これが今回のログと一致する形式）
          final quizJson = decodedData['quiz'];
          // debugPrint('Parsed Quiz Data (from Map): $quizJson');
          if (quizJson != null) {
            // quizJsonがMapでもListでも対応できるように修正
            if (quizJson is Map<String, dynamic>) {
              _dailyQuestion = QuizQuestion.fromJson(quizJson);
              debugPrint('クイズの中${_dailyQuestion?.questionText}');
            } else if (quizJson is List && quizJson.isNotEmpty) {
              _dailyQuestion = QuizQuestion.fromJson(quizJson[0]);
              // debugPrint('クイズの中（リスト形式）${_dailyQuestion?.questionText}');
            } else {
              _errorMessage = (_errorMessage ?? '') + 'クイズデータが見つからないか無効です。';
              debugPrint('Error: Quiz data is empty or invalid in Map.');
            }
          } else {
            _errorMessage = (_errorMessage ?? '') + 'クイズデータが見つかりません。';
          }

          final countData = decodedData['count'];
          debugPrint('Parsed Count Data (from Map): $countData');
          if (countData != null && countData is Map<String, dynamic>) {
            final percent = countData['percent'];
            // percentがnullまたは無効な場合は0.0にする
            if (percent != null && (percent is double || percent is int)) {
              _overallProgressPercent = (percent as num).toDouble();
            } else {
              _overallProgressPercent = 0.0; // 無効な場合は0.0に設定
              _errorMessage =
                  (_errorMessage ?? '') +
                  '\n総合パーセンテージデータが見つからないか無効です。0%に設定しました。';
            }

            final Map<String, Map<String, int>> tempCategoryCounts = {};
            final List<String> categories = ['turtle', 'flower', 'shrine'];
            for (var category in categories) {
              final categoryMap = countData[category];
              debugPrint(
                'Parsed Category "$category" Data (from Map): $categoryMap',
              );
              if (categoryMap != null && categoryMap is Map<String, dynamic>) {
                final count = categoryMap['count'];
                final all = categoryMap['all'];
                if (count != null &&
                    count is int &&
                    all != null &&
                    all is int) {
                  tempCategoryCounts[category] = {'count': count, 'all': all};
                } else {
                  // count, all のどちらかが無効な場合は0で初期化
                  tempCategoryCounts[category] = {'count': 0, 'all': 0};
                  _errorMessage =
                      (_errorMessage ?? '') +
                      '\n$categoryカテゴリのカウントデータが無効です。0で初期化しました。';
                }
              } else {
                // categoryMap が null の場合は0で初期化
                tempCategoryCounts[category] = {'count': 0, 'all': 0};
                _errorMessage =
                    (_errorMessage ?? '') +
                    '\n$categoryカテゴリデータが見つかりません。0で初期化しました。';
              }
            }
            _categoryCounts = tempCategoryCounts; // ここで_categoryCountsがセットされる
          } else {
            // countDataがnullまたは無効な場合は、_overallProgressPercentと_categoryCountsをデフォルト値にリセット
            _overallProgressPercent = 0.0;
            _categoryCounts = {};
            _errorMessage =
                (_errorMessage ?? '') + '\nカウントデータが見つからないか無効です。0%としました。';
          }
        } else if (decodedData is List) {
          // レスポンスがListの場合（トップレベルがクイズリストの場合）
          if (decodedData.isNotEmpty &&
              decodedData[0] is Map<String, dynamic>) {
            _dailyQuestion = QuizQuestion.fromJson(decodedData[0]);
            debugPrint(
              'Parsed Daily Quiz Data (from List): ${_dailyQuestion?.questionText}',
            );
          } else {
            _errorMessage = (_errorMessage ?? '') + 'クイズデータが見つからないか無効です。';
            debugPrint('Error: Quiz data is empty or not a Map in list.');
          }
          // リスト形式の場合、カウントデータは別途取得するか、APIレスポンスの変更が必要
          _overallProgressPercent = 0.0; // デフォルト値を0.0に設定
          _categoryCounts = {}; // デフォルトで空のマップに設定
          // このケースではcountデータが存在しないので、エラーメッセージは不要
        } else {
          // どちらの形式でもない場合
          _errorMessage = 'APIレスポンスの形式が無効です。';
          debugPrint('Error: API response is neither a List nor a Map.');
        }
      } else {
        _errorMessage = 'データの取得に失敗しました: ${response.statusCode}';
        debugPrint('HomePage APIエラー: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'ネットワークエラーまたはJSONパースエラー: $e';
      debugPrint('HomePage 通信エラー: $e');
    } finally {
      // 必ずsetStateを呼んでUIを更新し、ローディングを解除
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

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  DailyQuizCard(
                    dailyQuestion: _dailyQuestion,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onRetry: _fetchTopPageData,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // SizedBox(
                  //   height: screenHeight * 0.35,
                  //   child: const TimelineScreen(),
                  // ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    height: screenHeight * 0.70,
                    child: const XOfficialNoticeScreen(),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  KanagawaLoveArea(
                    overallProgressPercent: _overallProgressPercent / 100.0,
                    categoryCounts: _categoryCounts,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onRetry: _fetchTopPageData,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  AdBanner(adUnitId: admobId!),
                  SizedBox(height: screenHeight * 0.02),
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
