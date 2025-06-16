import 'package:flutter/material.dart'; // FlutterのUIコンポーネントを使用するために必要

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Map<String, Map<String, Color>> categoryColors;

  const CategoryTabs({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categoryColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // タブの数を取得
    final int numberOfCategories = categoryColors.keys.length;

    // 画面幅に基づいたタブの幅と高さ、フォントサイズを計算
    // タブ間の余白をなくすため、画面幅をカテゴリ数で均等に分割し、調整係数をかけます。
    // 少し余裕を持たせて、画面の端にわずかなパディングを残すようにします。
    final double tabWidth =
        (screenWidth / numberOfCategories) * 0.91; // 画面幅をカテゴリ数で割り、98%を使用
    final double tabHeight = screenHeight * 0.06; // 例: 画面高さの6%を各タブの高さとする

    // フォントサイズも画面幅に応じて調整
    // 小さめの画面でも読めるように最小値を考慮しても良いかもしれません
    final double fontSize = screenWidth * 0.04; // 画面幅の約4%をフォントサイズとする

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        // タブ間の余白がなくなるため、mainAxisAlignmentはCenterで問題ありません
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            categoryColors.keys.map((category) {
              return GestureDetector(
                onTap: () => onCategorySelected(category),
                child: Container(
                  width: tabWidth, // レスポンシブな幅
                  height: tabHeight, // レスポンシブな高さ
                  // タブ間のマージンを削除
                  // margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
                  decoration: BoxDecoration(
                    color:
                        selectedCategory == category
                            ? categoryColors[category]!["main"]
                            : categoryColors[category]!["sub"],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    // テキストがはみ出るのを防ぐために必須
                    fit: BoxFit.scaleDown, // 必要に応じてテキストを縮小
                    // テキストに最低限のパディングを追加して、タブの端に文字がくっつくのを防ぐ
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ), // テキスト内のパディング
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: fontSize, // レスポンシブなフォントサイズ
                          color:
                              selectedCategory == category
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
