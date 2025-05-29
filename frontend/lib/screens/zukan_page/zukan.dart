import 'package:flutter/material.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/screens/zukan_page/zukan_card.dart'; // ZukanCardとZukanItemが必要
import 'package:frontend/widgets/colors.dart';
import 'package:frontend/widgets/search_bar_widget.dart';
import 'package:frontend/widgets/category_tabs.dart';
import 'package:frontend/screens/zukan_page/zukan_list_container.dart';

class Zukan extends StatefulWidget {
  const Zukan({super.key});

  @override
  State<Zukan> createState() => _ZukanState();
}

class _ZukanState extends State<Zukan> {
  String selectedCategory = "すべて";
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // カテゴリと対応するカラー
  final Map<String, Map<String, Color>> categoryColors = {
    "すべて": {"main": AppColors.orange, "sub": AppColors.orangeSub},
    "おはな": {"main": AppColors.pink, "sub": AppColors.pinkSub},
    "じんじゃ": {"main": AppColors.red, "sub": AppColors.redSub},
    "かめ太郎": {"main": AppColors.blue, "sub": AppColors.blueSub},
  };

  // 仮の図鑑データ (実際はバックエンドから取得)
  List<ZukanItem> allZukanItems = [
    ZukanItem(
      id: 'sugiyama1',
      name: 'すぎやまじんじゃ　杉山神社',
      imageUrl: 'images/sugiyama_jinja.jpg',
      discoveredDate: '2025年5月5日',
      isDiscovered: true,
      category: 'じんじゃ',
    ),
    ZukanItem(
      id: 'kame_mystery',
      name: '謎のカメ太郎オブジェ',
      isDiscovered: false,
      category: 'かめ太郎',
    ),
    ZukanItem(
      id: 'jindaiji',
      name: 'じんだいでらじんじゃ　神大寺神明社',
      imageUrl: 'images/jindaiji_jinja.jpg',
      discoveredDate: '2025年5月10日',
      isDiscovered: true,
      category: 'じんじゃ',
    ),
    ZukanItem(
      id: 'sugiyama2',
      name: '杉山神社（2）',
      isDiscovered: false,
      category: 'じんじゃ',
    ),
    ZukanItem(
      id: 'kame_park',
      name: '公園のカメ太郎オブジェ',
      discoveredDate: '2025年5月15日',
      imageUrl: 'images/kame_park.jpg',
      isDiscovered: true,
      category: 'かめ太郎',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  ));
          return categoryMatches && searchMatches;
        }).toList();

    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          const SizedBox(height: 15.0),

          // 検索バー
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
          const SizedBox(height: 20.0),

          // カテゴリタブ
          CategoryTabs(
            selectedCategory: selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
            categoryColors: categoryColors,
          ),

          // 図鑑リストコンテナ
          Expanded(
            child: ZukanListContainer(
              selectedCategory: selectedCategory,
              filteredItems: filteredItems,
              categoryColors: categoryColors,
              allZukanItems: allZukanItems, // メッセージ表示のために渡す
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
      bottomNavigationBar: const Control(),
    );
  }
}
