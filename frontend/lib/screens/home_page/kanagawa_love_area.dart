import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoIconsを使用するために必要
import 'package:frontend/widgets/colors.dart';
import 'package:percent_indicator/percent_indicator.dart'; // 円形プログレスバーのパッケージ

class KanagawaLoveArea extends StatelessWidget {
  const KanagawaLoveArea({super.key});

  // ダミーデータ（実際のアプリでは、ユーザーの発見状況などから動的に取得します）
  // ZukanItemなどの実際のデータ構造と連携して、totalやcollectedを計算するロジックが必要になります。
  final int totalItems = 100; // 例: 全ての図鑑アイテムの合計数
  final int collectedItems = 25; // 例: ユーザーが発見済みの図鑑アイテムの合計数

  final List<LoveCategoryData> categoriesData = const [
    LoveCategoryData(
      label: 'おはな',
      icon: Icons.local_florist,
      total: 20,
      collected: 12,
      color: AppColors.pink,
      subColor: AppColors.pinkSub,
      categoryType: 'おはな',
    ),
    LoveCategoryData(
      label: 'かめ太郎',
      icon: CupertinoIcons.tortoise, // 亀のアイコン
      total: 15,
      collected: 8,
      color: AppColors.blue,
      subColor: AppColors.blueSub,
      categoryType: 'かめ太郎',
    ),
    LoveCategoryData(
      label: 'じんじゃ',
      icon: Icons.temple_hindu,
      total: 25,
      collected: 18,
      color: AppColors.red,
      subColor: AppColors.redSub,
      categoryType: 'じんじゃ',
    ),
  ];

  // 総合進捗の計算
  double get overallProgress => collectedItems / totalItems;

  // 総合進捗に応じたメッセージ
  String get overallProgressMessage {
    if (overallProgress == 1.0) {
      return 'コンプリートおめでとう！\nぜんぶ見つけられたね！';
    } else if (overallProgress >= 0.7) {
      return 'すごーい！\nあと少しでコンプリートだよ！';
    } else if (overallProgress >= 0.3) {
      return 'よくがんばってるね！\nだいぶ集まってきたよ！';
    } else {
      return 'はじまりはじまり！\nまだまだこれからだよ！';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 総合ラブ度タイル（全体の進捗を表示）
          _buildOverallLoveTile(context),
          const SizedBox(height: 20), // 間隔を広げて見やすく
          // カテゴリ別ラブ度タイル（各カテゴリの進捗を表示）
          GridView.count(
            shrinkWrap: true, // GridViewのサイズを子ウィジェットに合わせて縮小
            physics: const NeverScrollableScrollPhysics(), // GridViewのスクロールを無効化
            crossAxisCount: 2, // 2列で表示
            crossAxisSpacing: 16, // 列間のスペース
            mainAxisSpacing: 16, // 行間のスペース
            children:
                categoriesData
                    .map((data) => _buildCategoryLoveTile(context, data))
                    .toList()
                  ..add(Image.asset("images/kametarou.png")),
          ),
        ],
      ),
    );
  }

  /// 総合ラブ度タイルを構築するウィジェット
  Widget _buildOverallLoveTile(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 角をさらに丸く
        color: Colors.white, // 背景色
        boxShadow: [
          // 影
          BoxShadow(
            color: Colors.black.withOpacity(0.18), // 影の色と透明度を調整
            blurRadius: 10, // 影のぼかし具合
            offset: const Offset(0, 5), // 影のオフセット
          ),
        ],
      ),
      padding: const EdgeInsets.all(25), // 内側のパディングを増やす
      child: Column(
        children: [
          Text(
            'きみの かなわがく らぶど💕',
            style: const TextStyle(
              fontSize: 28, // 文字サイズを大きく
              fontWeight: FontWeight.w900, // さらに太く
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20), // 間隔を広げて見やすく
          CircularPercentIndicator(
            radius: 85.0, // 円の半径を調整
            lineWidth: 18.0, // 線幅をさらに太く
            percent: overallProgress,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$collectedItems', // 獲得数を表示
                  style: const TextStyle(
                    fontSize: 50, // 数字をさらに大きく
                    fontWeight: FontWeight.w900, // さらに太く
                    color: AppColors.mainGreen, // メインカラー
                  ),
                ),
                const Text(
                  '%', // 単位
                  style: TextStyle(
                    fontSize: 30, // 単位の文字サイズ
                    fontWeight: FontWeight.w900, // さらに太く
                    color: AppColors.mainGreen,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round, // プログレスバーの端を丸く
            backgroundColor: Colors.grey.shade100, // 未達成部分の色をより明るく
            progressColor: AppColors.mainGreen, // 達成部分の色
            animation: true, // アニメーションを有効に
            animateFromLastPercent: true, // 前回のパーセントからアニメーション
            animationDuration: 1500, // アニメーションの時間を長く
            footer: Padding(
              padding: const EdgeInsets.only(top: 20), // フッターとの間隔
              child: Text(
                overallProgressMessage, // 進捗メッセージ
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18, // メッセージの文字サイズ
                  fontWeight: FontWeight.w800, // 太字に
                  color: Colors.black54,
                ),
              ),
            ),
            widgetIndicator:
                overallProgress < 1.0
                    ? const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.white,
                    )
                    : null, // 矢印インジケーター
          ),
        ],
      ),
    );
  }

  /// カテゴリ別ラブ度タイルを構築するウィジェット
  Widget _buildCategoryLoveTile(BuildContext context, LoveCategoryData data) {
    final double progress = data.collected / data.total;
    return InkWell(
      // タップ可能にする
      onTap: () {
        // TODO: ここに各カテゴリの詳細画面への遷移処理を実装します。

        // 例: Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetailPage(category: data.categoryType)));
        print('${data.label} カテゴリがタップされました');
      },
      borderRadius: BorderRadius.circular(15), // 角丸を少し大きめに
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: data.subColor, // サブカラーを背景に使用
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12), // 影を調整
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
                color: data.color, // カテゴリの色
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ), // パディングを調整
              child: Row(
                children: [
                  Icon(data.icon, size: 32, color: Colors.white), // アイコンサイズを大きく
                  const SizedBox(width: 8), // アイコンとラベルの間隔
                  Expanded(
                    // ラベルが長い場合に対応
                    child: Text(
                      data.label,
                      style: const TextStyle(
                        fontSize: 20, // ラベルの文字サイズを調整
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis, // 長すぎる場合は省略
                    ),
                  ),
                ],
              ),
            ),
            // 進捗表示部分
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0), // パディングを調整
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data.collected} / ${data.total}', // 収集数 / 総数
                      style: const TextStyle(
                        fontSize: 34, // 数字を大きく
                        fontWeight: FontWeight.w900, // さらに太く
                        color: Colors.black87, // 濃い色で見やすく
                      ),
                    ),
                    const SizedBox(height: 10), // 数字とバーの間隔
                    LinearPercentIndicator(
                      lineHeight: 12.0, // バーの太さ
                      percent: progress,
                      backgroundColor: Colors.grey.shade100, // 未達成部分の色をより明るく
                      progressColor: data.color, // 達成部分の色をそのまま使用
                      barRadius: const Radius.circular(6), // バーの端を丸く
                      animation: true, // アニメーションを有効に
                      animateFromLastPercent: true, // 前回のパーセントからアニメーション
                      animationDuration: 1000, // アニメーションの時間
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

/// 各カテゴリのデータを保持するクラス
class LoveCategoryData {
  final String label;
  final IconData icon;
  final int total;
  final int collected;
  final Color color;
  final Color subColor;
  final String categoryType;

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
