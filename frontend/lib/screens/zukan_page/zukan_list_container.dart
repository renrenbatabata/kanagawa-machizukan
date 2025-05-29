import 'package:flutter/material.dart';
import 'package:frontend/screens/zukan_page/zukan_card.dart'; // ZukanCardをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート

class ZukanListContainer extends StatelessWidget {
  final String selectedCategory;
  final List<ZukanItem> filteredItems;
  final Map<String, Map<String, Color>> categoryColors;
  final List<ZukanItem> allZukanItems; // お花モデルメッセージのために必要

  const ZukanListContainer({
    Key? key,
    required this.selectedCategory,
    required this.filteredItems,
    required this.categoryColors,
    required this.allZukanItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // お花カテゴリで、かつ該当する発見済みのアイテムがない場合にメッセージを表示
    final bool showFlowerPromptMessage =
        selectedCategory == "おはな" &&
        !allZukanItems.any(
          (item) => item.category == 'おはな' && item.isDiscovered,
        );

    return Container(
      decoration: BoxDecoration(
        color: categoryColors[selectedCategory]!["main"],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2.0),
          topRight: Radius.circular(2.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Column(
        children: [
          // お花を撮影して図鑑に登録するメッセージ
          if (showFlowerPromptMessage) // 条件がtrueの場合のみ表示
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: AppColors.white,
                  ), // カメラアイコンに変更
                  const SizedBox(height: 10),
                  Text(
                    '🌸 お花をさつえいして ずかんにとうろくしよう！ 🌸', // メッセージを変更
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // カメ太郎のイメージを、撮影を促すポーズなどに変更すると良い
                  Image.asset('images/kame_pointing_camera.png', height: 100),
                ],
              ),
            ),
          // 図鑑アイテムのリスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0.0, bottom: 20.0),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ZukanCard(
                  item: filteredItems[index],
                  cardColor: AppColors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
