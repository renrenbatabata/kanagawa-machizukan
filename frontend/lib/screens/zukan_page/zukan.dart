import 'package:flutter/material.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/colors.dart';
import 'package:frontend/widgets/search_bar_widget.dart';
import 'package:frontend/widgets/category_tabs.dart';
import 'package:frontend/screens/zukan_page/zukan_list_container.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート
import 'package:frontend/screens/zukan_page/zukan_card.dart' show ZukanItem;

class Zukan extends StatefulWidget {
  const Zukan({super.key});

  @override
  State<Zukan> createState() => _ZukanState();
}

class _ZukanState extends State<Zukan> {
  String selectedCategory = "すべて";
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  List<ZukanItem> allZukanItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, Map<String, Color>> categoryColors = {
    "すべて": {"main": AppColors.orange, "sub": AppColors.orangeSub},
    "おはな": {"main": AppColors.pink, "sub": AppColors.pinkSub},
    "じんじゃ": {"main": AppColors.red, "sub": AppColors.redSub},
    "かめ太郎": {"main": AppColors.blue, "sub": AppColors.blueSub},
  };

  @override
  void initState() {
    super.initState();
    _fetchZukanItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // バックエンドから図鑑データを取得する非同期メソッド
  Future<void> _fetchZukanItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      setState(() {
        _errorMessage = 'Error: BASE_API_URLが設定されていません。';
        _isLoading = false;
      });
      print('❌ BASE_API_URLが設定されていません。');
      return;
    }

    // ⭐ 修正箇所: AuthService().currentUserId から userId を取得
    final String? userId = AuthService().currentUserId;

    // userId が null の場合はエラー表示
    if (userId == null) {
      setState(() {
        _errorMessage = 'Error: ログインユーザーのIDが取得できませんでした。ログイン状態を確認してください。';
        _isLoading = false;
      });
      print('警告: userIdがnullです。ログイン状態を確認してください。');
      return; // userIdがない場合はここで処理を終了
    }

    final String apiCategory =
        selectedCategory == "すべて"
            ? "all"
            : selectedCategory; // "すべて"の場合は"all"をAPIに送信

    final uri = Uri.parse(
      '$baseUrl/allPictures',
    ).replace(queryParameters: {'userId': userId, 'category': apiCategory});

    try {
      final response = await http.post(uri); // POSTリクエストを送信

      // --- デバッグ情報 ---
      print('--- API Response Debug ---');
      print('URL: $uri');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('--- End API Response Debug ---');
      // --- デバッグ情報ここまで ---

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          allZukanItems =
              jsonList.map((json) => ZukanItem.fromJson(json)).toList();
          _isLoading = false;

          print('図鑑アイテムの取得に成功: ${allZukanItems.length}件');
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load zukan items. Status code: ${response.statusCode}. Response Body: ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      print('Error fetching zukan items: $e');
    }
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
                _fetchZukanItems(); // カテゴリが変わったら再度データを取得
              });
            },
            categoryColors: categoryColors,
          ),

          // 図鑑リストコンテナ
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _fetchZukanItems,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : ZukanListContainer(
                      selectedCategory: selectedCategory,
                      filteredItems: filteredItems,
                      categoryColors: categoryColors,
                      allZukanItems: allZukanItems,
                    ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
      bottomNavigationBar: const Control(),
    );
  }
}
