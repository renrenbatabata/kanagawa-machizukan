import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoIconsを使用するために必要
import 'package:frontend/widgets/colors.dart';
import 'package:percent_indicator/percent_indicator.dart'; // 円形プログレスバーのパッケージ
import 'package:http/http.dart' as http; // HTTPリクエストを送信するために必要
import 'dart:convert'; // JSONデータのデコードのために必要
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .envファイルから環境変数を読み込むため
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート
import 'package:frontend/screens/zukan_page/zukan_card.dart'
    show ZukanItem; // ZukanItemモデルをインポート

// KanagawaLoveArea クラス
// 神奈川の図鑑ラブ度（進捗状況）を表示するウィジェットです。
// データベースの情報を可視化するため、StatefulWidgetに変更しました。
class KanagawaLoveArea extends StatefulWidget {
  const KanagawaLoveArea({super.key});

  @override
  State<KanagawaLoveArea> createState() => _KanagawaLoveAreaState();
}

class _KanagawaLoveAreaState extends State<KanagawaLoveArea> {
  List<ZukanItem> _allZukanItems = []; // バックエンドから取得した全ての図鑑アイテム
  bool _isLoading = true; // データロード中かどうかのフラグ
  String? _errorMessage; // エラーメッセージ

  // カテゴリごとの設定（アイコン、色、バックエンドのカテゴリタイプ）
  // このリストを基に、各カテゴリのデータを動的に計算します。
  final List<LoveCategoryConfig> _categoryConfigs = const [
    LoveCategoryConfig(
      label: 'おはな',
      icon: Icons.local_florist,
      color: AppColors.pink,
      subColor: AppColors.pinkSub,
      backendCategoryType: 'flower', // バックエンドのカテゴリ名
    ),
    LoveCategoryConfig(
      label: 'かめ太郎',
      icon: CupertinoIcons.tortoise,
      color: AppColors.blue,
      subColor: AppColors.blueSub,
      backendCategoryType: 'turtle', // バックエンドのカテゴリ名
    ),
    LoveCategoryConfig(
      label: 'じんじゃ',
      icon: Icons.temple_hindu,
      color: AppColors.red,
      subColor: AppColors.redSub,
      backendCategoryType: 'shrine', // バックエンドのカテゴリ名
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchZukanProgress(); // ウィジェット初期化時にデータ取得を開始
  }

  // バックエンドから図鑑の全アイテムデータを取得する非同期メソッド
  Future<void> _fetchZukanProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = dotenv.env['BASE_API_URL'];
    final userId = AuthService().currentUserId;

    if (baseUrl == null) {
      _errorMessage = 'Error: BASE_API_URLが設定されていません。';
      _isLoading = false;
      print('❌ BASE_API_URLが設定されていません。');
      return;
    }
    if (userId == null) {
      _errorMessage = 'Error: ユーザーIDが取得できません。ログイン状態を確認してください。';
      _isLoading = false;
      print('❌ ユーザーIDがnullです。');
      return;
    }

    // 全てのカテゴリのアイテムを取得するため、categoryは"all"をAPIに送る
    final uri = Uri.parse(
      '$baseUrl/allPictures',
    ).replace(queryParameters: {'userId': userId, 'category': 'all'});

    try {
      final response = await http.post(uri); // POSTリクエストを送信

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _allZukanItems =
              jsonList.map((json) => ZukanItem.fromJson(json)).toList();
          _isLoading = false;
          print('✅ 図鑑アイテムの進捗データ取得成功: ${_allZukanItems.length}件');
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load zukan progress. Status code: ${response.statusCode}. Body: ${response.body}';
          _isLoading = false;
          print(
            '❌ 図鑑進捗取得サーバーエラー: ${response.statusCode}, Body: ${response.body}',
          );
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching zukan progress: $e';
        _isLoading = false;
        print('❌ 図鑑進捗通信エラー: $e');
      });
    }
  }

  // 総合進捗の計算
  // allZukanItemsリストの合計数と収集数を動的に計算します。
  int get _totalItems => _allZukanItems.length; // データベースにある全てのアイテムの合計
  int get _collectedItems =>
      _allZukanItems
          .where((item) => true)
          .length; // 全てのアイテムは発見済みとして扱うため、常に_allZukanItems.length

  // 総合進捗のパーセンテージ
  double get _overallProgress =>
      _totalItems > 0 ? _collectedItems / _totalItems : 0.0;

  // 総合進捗に応じたメッセージ
  String get _overallProgressMessage {
    if (_overallProgress == 1.0) {
      return 'コンプリートおめでとう！\nぜんぶ見つけられたね！';
    } else if (_overallProgress >= 0.7) {
      return 'すごーい！\nあと少しでコンプリートだよ！';
    } else if (_overallProgress >= 0.3) {
      return 'よくがんばってるね！\nだいぶ集まってきたよ！';
    } else {
      return 'はじまりはじまり！\nまだまだこれからだよ！';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator()); // ローディング中の表示
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラー: $_errorMessage'), // エラーメッセージ表示
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchZukanProgress, // リトライボタン
              child: const Text('リトライ'),
            ),
          ],
        ),
      );
    }

    // カテゴリ別ラブ度データを動的に生成
    final List<LoveCategoryData> categoriesData =
        _categoryConfigs.map((config) {
          final int categoryTotal =
              _allZukanItems
                  .where((item) => item.category == config.backendCategoryType)
                  .length;
          final int categoryCollected = // すべてのアイテムが発見済みなので、総数と同じ
              _allZukanItems
                  .where((item) => item.category == config.backendCategoryType)
                  .length;

          return LoveCategoryData(
            label: config.label,
            icon: config.icon,
            total: categoryTotal,
            collected: categoryCollected,
            color: config.color,
            subColor: config.subColor,
            categoryType:
                config
                    .backendCategoryType, // ZukanCardとの連携のためbackendCategoryTypeを使用
          );
        }).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: const Color.fromARGB(255, 254, 255, 253),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 総合ラブ度タイル（全体の進捗を表示）
            _buildOverallLoveTile(context),
            const SizedBox(height: 20), // 間隔を広げて見やすく
            // カテゴリ別ラブ度タイル（各カテゴリの進捗を表示）
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children:
                  categoriesData
                      .map((data) => _buildCategoryLoveTile(context, data))
                      .toList()
                    ..add(Image.asset("images/kametarou.png")), // 「かめ太郎」画像を追加
            ),
          ],
        ),
      ),
    );
  }

  /// 総合ラブ度タイルを構築するウィジェット
  Widget _buildOverallLoveTile(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🏆きみの ずかん たっせいど',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
        CircularPercentIndicator(
          radius: 85.0,
          lineWidth: 18.0,
          percent: _overallProgress, // ⭐ 修正: 動的に計算した進捗を使用
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(_overallProgress * 100).toInt()}', // ⭐ 修正: パーセンテージを整数で表示
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: AppColors.mainGreen,
                ),
              ),
              const Text(
                '％',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.mainGreen,
                ),
              ),
            ],
          ),
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.grey.shade100,
          progressColor: AppColors.mainGreen,
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 1500,
          footer: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _overallProgressMessage, // ⭐ 修正: 動的に計算したメッセージを使用
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// カテゴリ別ラブ度タイルを構築するウィジェット
  Widget _buildCategoryLoveTile(BuildContext context, LoveCategoryData data) {
    final double progress =
        data.total > 0 ? data.collected / data.total : 0.0; // ⭐ 修正: 0除算対策
    return InkWell(
      onTap: () {
        // TODO: ここに各カテゴリの詳細画面への遷移処理を実装します。
        // 例えば、カテゴリ名をZukanページに渡してフィルタリング表示する
        print('${data.label} カテゴリがタップされました');
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: data.subColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトルバー（色付きの部分）
            Container(
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  Icon(data.icon, size: 32, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // 進捗表示部分
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data.collected} / ${data.total}', // 収集数 / 総数
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearPercentIndicator(
                      lineHeight: 12.0,
                      percent: progress,
                      backgroundColor: Colors.grey.shade100,
                      progressColor: data.color,
                      barRadius: const Radius.circular(6),
                      animation: true,
                      animateFromLastPercent: true,
                      animationDuration: 1000,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 各カテゴリのデータを保持するクラス（ウィジェット内で動的に生成されるため、変更なし）
class LoveCategoryData {
  final String label;
  final IconData icon;
  final int total;
  final int collected;
  final Color color;
  final Color subColor;
  final String categoryType; // カテゴリタイプ（ZukanCardとの連携用）

  const LoveCategoryData({
    required this.label,
    required this.icon,
    required this.total,
    required this.collected,
    required this.color,
    required this.subColor,
    required this.categoryType,
  });
}

// ⭐ 新規追加: カテゴリ設定を保持するクラス
// これにより、UIの表示ラベルとバックエンドのカテゴリタイプを紐付けます。
class LoveCategoryConfig {
  final String label; // UIに表示する日本語ラベル
  final IconData icon; // 表示するアイコン
  final Color color; // メインカラー
  final Color subColor; // サブカラー
  final String
  backendCategoryType; // バックエンドのカテゴリ名 (例: 'flower', 'shrine', 'kame')

  const LoveCategoryConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.subColor,
    required this.backendCategoryType,
  });
}
