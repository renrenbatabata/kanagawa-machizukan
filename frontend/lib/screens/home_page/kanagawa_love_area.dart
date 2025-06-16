import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // CupertinoIconsを使用するために必要
import 'package:frontend/widgets/colors.dart';
import 'package:percent_indicator/percent_indicator.dart'; // 円形プログレスバーのパッケージ

// KanagawaLoveArea クラス
// 神奈川の図鑑ラブ度（進捗状況）を表示するウィジェットです。
// ホームページからデータを直接受け取るようにStatelessWidgetに変更されています。
class KanagawaLoveArea extends StatelessWidget {
  // ★ 変更: overallCollected/overallTotalの代わりにoverallProgressPercentを受け取る
  final double? overallProgressPercent; // Javaで計算済みの総合パーセンテージ (0.0〜1.0)
  final Map<String, Map<String, int>> categoryCounts; // カテゴリごとのカウントデータ
  final bool isLoading; // ロード中フラグ
  final String? errorMessage; // エラーメッセージ
  final VoidCallback? onRetry; // リトライ用コールバック

  const KanagawaLoveArea({
    super.key,
    this.overallProgressPercent, // Nullable
    required this.categoryCounts, // 必須
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
  });

  // カテゴリごとの設定（アイコン、色、バックエンドのカテゴリタイプ）
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
      label: 'れきし',
      icon: Icons.temple_hindu,
      color: AppColors.red,
      subColor: AppColors.redSub,
      backendCategoryType: 'shrine', // バックエンドのカテゴリ名
    ),
  ];

  // 総合進捗のメッセージ
  // ★ 変更: overallProgressPercentに基づいてメッセージを生成
  String get _overallProgressMessage {
    final progress = overallProgressPercent ?? 0.0; // nullの場合は0.0として扱う
    if (progress >= 1.0) {
      // 1.0は100%
      return 'コンプリートおめでとう！\nぜんぶ見つけられたね！';
    } else if (progress >= 0.7) {
      return 'すごーい！\nあと少しでコンプリートだよ！';
    } else if (progress >= 0.3) {
      return 'よくがんばってるね！\nだいぶ集まってきたよ！';
    } else {
      return 'はじまりはじまり！\nまだまだこれからだよ！';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 300, // ローディング時に適切な高さを確保
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // ★ 変更: overallProgressPercentがnullの場合もエラーとみなす
    if (errorMessage != null || overallProgressPercent == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 300, // エラー時に適切な高さを確保
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage ?? '図鑑の進捗を読み込めませんでした。'),
              const SizedBox(height: 10),
              if (onRetry != null)
                ElevatedButton(onPressed: onRetry, child: const Text('リトライ')),
            ],
          ),
        ),
      );
    }

    // カテゴリ別ラブ度データを動的に生成
    final List<LoveCategoryData> categoriesData =
        _categoryConfigs.map((config) {
          final categoryMap = categoryCounts[config.backendCategoryType];
          final int categoryTotal = categoryMap?['all'] ?? 0;
          final int categoryCollected = categoryMap?['count'] ?? 0;

          return LoveCategoryData(
            label: config.label,
            icon: config.icon,
            total: categoryTotal,
            collected: categoryCollected,
            color: config.color,
            subColor: config.subColor,
            categoryType: config.backendCategoryType,
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
    // overallProgressPercentがnullでないことを保証
    final displayProgress = overallProgressPercent ?? 0.0;

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
          percent: displayProgress, // ★ 変更: Javaから受け取ったパーセンテージを使用
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(displayProgress * 100).toInt()}', // ★ 変更: パーセンテージを整数で表示
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
              _overallProgressMessage, // Javaから提供されたパーセントに基づいてメッセージを生成
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
    final double progress = data.total > 0 ? data.collected / data.total : 0.0;
    return InkWell(
      onTap: () {
        debugPrint('${data.label} カテゴリがタップされました');
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data.collected} / ${data.total}',
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

class LoveCategoryConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color subColor;
  final String backendCategoryType;

  const LoveCategoryConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.subColor,
    required this.backendCategoryType,
  });
}
