import 'package:flutter/material.dart';
import 'package:frontend/screens/zukan_page/zukan_card.dart'; // ZukanCardをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート

class ZukanListContainer extends StatelessWidget {
  final String selectedCategory;
  final List<ZukanItem> filteredItems;
  final Map<String, Map<String, Color>> categoryColors;
  final List<ZukanItem> allZukanItems; // お花モデルメッセージのために必要

  const ZukanListContainer({
    super.key,
    required this.selectedCategory,
    required this.filteredItems,
    required this.categoryColors,
    required this.allZukanItems,
  });

  @override
  Widget build(BuildContext context) {
    // 現在選択されているカテゴリに対応するメインカラーを取得（デフォルトはオレンジ）
    final Color currentContainerColor =
        categoryColors[selectedCategory]?['main'] ?? AppColors.orange;
    final Color currentCardColor =
        categoryColors[selectedCategory]?['sub'] ??
        AppColors.orangeSub; // カードのサブカラーを使うことが多いです

    // お花カテゴリで、かつ該当する発見済みのアイテムがない場合にメッセージを表示
    final bool showFlowerPromptMessage =
        selectedCategory == "おはな" &&
        !allZukanItems.any(
          (item) =>
              item.category == 'flower' &&
              item.isDiscovered, // ZukanItemのcategoryは'flower'であることを想定
        );

    // フィルタリング後のリストが空の場合のメッセージ表示を制御するフラグ
    // ただし、お花のプロンプトメッセージが優先される
    final bool showEmptyStateMessage =
        filteredItems.isEmpty && !showFlowerPromptMessage;

    return Container(
      decoration: BoxDecoration(
        color: currentContainerColor, // カテゴリに応じた背景色
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2.0),
          topRight: Radius.circular(2.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Column(
        children: [
          // ⭐ お花を撮影して図鑑に登録するメッセージ
          if (showFlowerPromptMessage)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.camera_alt, size: 50, color: AppColors.white),
                  const SizedBox(height: 10),
                  Text(
                    '🌸 お花をさつえいして ずかんにとうろくしよう！ 🌸',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('images/kame_pointing_camera.png', height: 100),
                ],
              ),
            )
          // ⭐ フィルタリングされたアイテムが空の場合のメッセージ (お花メッセージと排他的)
          else if (showEmptyStateMessage)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    selectedCategory == "すべて"
                        ? 'まだ何も発見されていません。\n新しい発見をしてみよう！'
                        : 'このカテゴリにはまだ発見されたアイテムがありません。\n新しい発見をしてみよう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            )
          // ⭐ 図鑑アイテムのリスト (アイテムがある場合のみ表示)
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ZukanCard(
                    item: filteredItems[index],
                    cardColor: currentCardColor, // ⭐ カテゴリに応じたカード色を渡す
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
