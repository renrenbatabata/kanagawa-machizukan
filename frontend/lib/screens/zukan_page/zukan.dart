import 'package:flutter/material.dart';
import 'package:frontend/widgets/ad_banner.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/screens/zukan_page/zukan_card.dart'; // ZukanCardをインポート
import 'package:frontend/widgets/colors.dart';

class Zukan extends StatefulWidget {
  const Zukan({super.key});

  @override
  State<Zukan> createState() => _ZukanState();
}

class _ZukanState extends State<Zukan> {
  String selectedCategory = "すべて";
  final TextEditingController _searchController =
      TextEditingController(); // 検索テキストコントローラー
  String _searchText = ""; // 検索テキストの状態

  // カテゴリと対応するカラー
  final Map<String, Map<String, Color>> categoryColors = {
    "すべて": {"main": AppColors.orange, "sub": AppColors.orangeSub},
    "おはな": {"main": AppColors.pink, "sub": AppColors.pinkSub},
    "じんじゃ": {"main": AppColors.red, "sub": AppColors.redSub},
    "かめ太郎": {"main": AppColors.blue, "sub": AppColors.blueSub},
  };

  // 仮の図鑑データ (実際はバックエンドから取得)
  // ZukanItemのリストとして定義
  List<ZukanItem> allZukanItems = [
    ZukanItem(
      id: 'sugiyama1',
      name: 'すぎやまじんじゃ　杉山神社',
      imageUrl: 'images/sugiyama_jinja.jpg', // 実際の画像パスに置き換える
      discoveredDate: '2025年5月5日',
      isDiscovered: true,
      category: 'じんじゃ', // ★追加：カテゴリ情報
    ),
    ZukanItem(
      id: 'kame_mystery',
      name: '謎のカメ太郎オブジェ',
      isDiscovered: false, // 未発見
      category: 'かめ太郎', // ★追加：カテゴリ情報
      // hintはZukanCard内部で取得
    ),
    ZukanItem(
      id: 'jindaiji',
      name: 'じんだいでらじんじゃ　神大寺神明社',
      imageUrl: 'images/jindaiji_jinja.jpg', // 実際の画像パスに置き換える
      discoveredDate: '2025年5月10日',
      isDiscovered: true,
      category: 'じんじゃ', // ★追加：カテゴリ情報
    ),
    ZukanItem(
      id: 'sugiyama2',
      name: '杉山神社（2）', // 別の子安台の杉山神社などを想定
      isDiscovered: false, // 未発見
      category: 'じんじゃ', // ★追加：カテゴリ情報
    ),
    ZukanItem(
      id: 'kame_park',
      name: '公園のカメ太郎オブジェ',
      discoveredDate: '2025年5月15日',
      imageUrl: 'images/kame_park.jpg', // 実際の画像パスに置き換える
      isDiscovered: true,
      category: 'かめ太郎', // ★追加：カテゴリ情報
    ),
    // ここに他の神社、カメ太郎、お花などのZukanItemを追加していく
    // 例: お花を追加
    // ZukanItem(
    //   id: 'flower_sakura',
    //   name: 'サクラ',
    //   isDiscovered: false,
    //   category: 'おはな',
    // ),
    // ZukanItem(
    //   id: 'flower_himawari',
    //   name: 'ヒマワリ',
    //   isDiscovered: false,
    //   category: 'おはな',
    // ),
  ];

  @override
  void dispose() {
    _searchController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 選択されたカテゴリと検索テキストに基づいてアイテムをフィルタリング
    List<ZukanItem> filteredItems =
        allZukanItems.where((item) {
          final bool categoryMatches =
              selectedCategory == "すべて" || item.category == selectedCategory;
          final bool searchMatches =
              _searchText.isEmpty ||
              item.name.toLowerCase().contains(_searchText.toLowerCase()) ||
              (item.discoveredDate != null &&
                  item.discoveredDate!.toLowerCase().contains(
                    _searchText.toLowerCase(),
                  )); // 発見日も検索対象に含める

          return categoryMatches && searchMatches;
        }).toList();

    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          const SizedBox(height: 20.0), // ヘッダーと検索バーの間のスペースを調整
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'なにをさがす？',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30.0), // 検索バーとカテゴリタブの間のスペースを調整
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    categoryColors.keys.map((category) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 50,
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
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  selectedCategory == category
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          Expanded(
            // Expandedで残りスペースをZukanCardのリストに割り当てる
            child: Container(
              // カテゴリタブ下のコンテナのスタイルを調整
              decoration: BoxDecoration(
                color: categoryColors[selectedCategory]!["main"],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2.0),
                  topRight: Radius.circular(2.0),
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 20.0,
                ), // リスト全体のパディング調整
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return ZukanCard(
                    item: filteredItems[index],
                    cardColor:
                        AppColors.white, // 各カードの背景色は白などにして、メインコンテナの色と区別する
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          const AdBanner(adUnitId: 'ca-app-pub-3940256099942544/6300978111'),

          const SizedBox(height: 10.0),
        ],
      ),
      bottomNavigationBar: const Control(),
    );
  }
}
