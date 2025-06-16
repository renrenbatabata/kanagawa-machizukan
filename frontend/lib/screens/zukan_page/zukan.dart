import 'package:flutter/material.dart'; // FlutterのUIコンポーネントを使用するために必要
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
import 'package:frontend/screens/zukan_page/zukan_card.dart'
    show ZukanItem; // ZukanItemモデルのみをインポート

// Zukan クラス
// アプリケーションの図鑑ページのメインウィジェットです。
// StatefulWidgetとして定義されており、状態（選択されたカテゴリ、検索テキスト、取得したアイテムなど）を管理します。
class Zukan extends StatefulWidget {
  const Zukan({super.key});

  @override
  State<Zukan> createState() => _ZukanState();
}

// _ZukanState クラス
// Zukanウィジェットの内部状態を管理するクラスです。
class _ZukanState extends State<Zukan> {
  String selectedCategory = "すべて"; // 現在選択されているカテゴリを保持する変数。初期値は「すべて」。
  final TextEditingController _searchController =
      TextEditingController(); // 検索バーのテキストを制御するためのコントローラー。
  String _searchText = ""; // 検索バーに入力されたテキストを保持する変数。
  List<ZukanItem> allZukanItems = []; // バックエンドから取得した全ての図鑑アイテムを保持するリスト。
  bool _isLoading = true; // データ取得中かどうかを示すフラグ。trueの間はローディングインジケーターが表示されます。
  String? _errorMessage; // データ取得中にエラーが発生した場合に表示するメッセージ。

  // 各カテゴリに対応する色を定義したマップです。
  // "main"はZukanListContainerの背景色、"sub"はZukanCardの背景色に使用されます。
  final Map<String, Map<String, Color>> categoryColors = {
    "すべて": {"main": AppColors.orange, "sub": AppColors.orangeSub},
    "おはな": {"main": AppColors.pink, "sub": AppColors.pinkSub},
    "じんじゃ": {"main": AppColors.red, "sub": AppColors.redSub},
    "かめ太郎": {"main": AppColors.blue, "sub": AppColors.blueSub},
  };

  @override
  void initState() {
    super.initState();
    // ウィジェットが作成された際に、初期データとして図鑑アイテムの取得を開始します。
    _fetchZukanItems();
  }

  @override
  void dispose() {
    // ウィジェットが破棄される際に、TextEditingControllerを解放してメモリリークを防ぎます。
    _searchController.dispose();
    super.dispose();
  }

  // バックエンドから図鑑データを取得する非同期メソッドです。
  // APIリクエストを送信し、レスポンスを解析してallZukanItemsリストを更新します。
  Future<void> _fetchZukanItems() async {
    setState(() {
      _isLoading = true; // データ取得開始のためローディング状態をtrueに設定
      _errorMessage = null; // エラーメッセージをリセット
    });

    final baseUrl = dotenv.env['BASE_API_URL']; // .envファイルからAPIのベースURLを取得
    // BASE_API_URLが設定されていない場合のエラーハンドリング
    if (baseUrl == null) {
      setState(() {
        _errorMessage = 'Error: BASE_API_URLが設定されていません。';
        _isLoading = false;
      });
      print('❌ BASE_API_URLが設定されていません。');
      return; // 処理を終了
    }

    // AuthServiceから現在のユーザーIDを取得します。
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

    // ⭐ 修正箇所: selectedCategory (日本語) に応じてAPIに送るカテゴリ名を決定
    final String apiCategory;
    switch (selectedCategory) {
      case "すべて":
        apiCategory = "all"; // バックエンドが全件取得に使うカテゴリ名
        break;
      case "おはな":
        apiCategory = "flower"; // バックエンドのカテゴリ名
        break;
      case "じんじゃ":
        apiCategory = "shrine"; // バックエンドのカテゴリ名
        break;
      case "かめ太郎":
        apiCategory = "turtle"; // バックエンドのカテゴリ名
        break;
      default:
        apiCategory = "all"; // 想定外のカテゴリの場合のデフォルト
        break;
    }

    // APIリクエストのURIを構築します。
    // ユーザーIDとカテゴリをクエリパラメータとして含めます。
    final uri = Uri.parse(
      '$baseUrl/allPictures', // 図鑑アイテムを取得するためのエンドポイント
    ).replace(queryParameters: {'userId': userId, 'category': apiCategory});

    try {
      final response = await http.post(uri); // POSTリクエストを送信してデータを取得

      // --- デバッグ情報 ---
      // APIリクエストとレスポンスの詳細をコンソールに出力します。
      print('--- API Response Debug ---');
      print('URL: $uri');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('--- End API Response Debug ---');
      // --- デバッグ情報ここまで ---

      if (response.statusCode == 200) {
        // HTTPステータスコードが200（成功）の場合
        List<dynamic> jsonList = json.decode(
          response.body,
        ); // レスポンスボディをJSONとしてデコード
        setState(() {
          // デコードしたJSONリストをZukanItemオブジェクトのリストに変換し、allZukanItemsを更新
          allZukanItems =
              jsonList.map((json) => ZukanItem.fromJson(json)).toList();
          _isLoading = false; // ローディング状態をfalseに設定
          print('図鑑アイテムの取得に成功: ${allZukanItems.length}件'); // 取得件数をコンソールに出力
        });
      } else {
        // 成功以外のステータスコードの場合（サーバーエラーなど）
        setState(() {
          _errorMessage =
              'Failed to load zukan items. Status code: ${response.statusCode}. Response Body: ${response.body}'; // エラーメッセージを設定
          _isLoading = false; // ローディング状態をfalseに設定
        });
      }
    } catch (e) {
      // ネットワークエラーなど、例外が発生した場合
      setState(() {
        _errorMessage = 'Error: $e'; // エラーメッセージを設定
        _isLoading = false; // ローディング状態をfalseに設定
      });
      print('Error fetching zukan items: $e'); // エラー詳細をコンソールに出力
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得
    final screenHeight = MediaQuery.of(context).size.height;

    // 現在のカテゴリと検索テキストに基づいて、表示するアイテムをフィルタリングします。
    List<ZukanItem> filteredItems =
        allZukanItems.where((item) {
          // ⭐ 修正箇所: selectedCategory (日本語) と item.category (バックエンドからの英語名) を比較
          final bool categoryMatches;
          switch (selectedCategory) {
            case "すべて":
              categoryMatches = true; // 「すべて」の場合は常にマッチ
              break;
            case "おはな":
              categoryMatches = item.category == "flower";
              break;
            case "じんじゃ":
              categoryMatches = item.category == "shrine";
              break;
            case "かめ太郎":
              categoryMatches =
                  item.category == "turtle"; // バックエンドのカテゴリ名に合わせてください
              break;
            default:
              categoryMatches = false; // 未知のカテゴリは表示しない
              break;
          }

          // 検索テキストによるフィルタリング条件
          // 検索テキストが空の場合、またはアイテム名、発見日が検索テキストを含む場合にtrue
          final bool searchMatches =
              _searchText.isEmpty ||
              item.name.toLowerCase().contains(
                _searchText.toLowerCase(),
              ) || // アイテム名で検索
              (item.shootingDate != null &&
                  item.shootingDate!.toLowerCase().contains(
                    _searchText.toLowerCase(),
                  )); // 発見日で検索

          // カテゴリと検索の両方の条件がtrueの場合に、そのアイテムを表示対象とします。
          return categoryMatches && searchMatches;
        }).toList();

    return Scaffold(
      body: Column(
        // ページの主要なコンテンツを縦に並べる
        children: [
          const ImageHeader(), // アプリケーションのヘッダー部分
          SizedBox(height: screenHeight * 0.015), // ヘッダーと検索バーの間のスペースをレスポンシブに
          // 検索バーウィジェット
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // 左右のパディングは固定で良い場合が多い
            child: SearchBarWidget(
              controller: _searchController, // 検索テキストの制御に使うコントローラー
              onChanged: (value) {
                // 検索テキストが変更されたら、Stateを更新し、リストを再フィルタリング
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02), // 検索バーとカテゴリタブの間のスペースをレスポンシブに
          // カテゴリタブウィジェット
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // 左右のパディングは固定で良い場合が多い
            child: CategoryTabs(
              selectedCategory: selectedCategory, // 現在選択されているカテゴリを渡す
              onCategorySelected: (category) {
                // カテゴリが選択されたら、Stateを更新し、新しいカテゴリでデータを再取得
                setState(() {
                  selectedCategory = category;
                  _fetchZukanItems(); // カテゴリが変わったら再度データを取得
                });
              },
              categoryColors: categoryColors, // カテゴリの色情報を渡す
            ),
          ),

          // 図鑑リストを表示する領域
          Expanded(
            // 残りの利用可能なスペースをすべて占める
            child:
                // データロード中であればローディングインジケーターを表示
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    // エラーメッセージがあればエラー表示とリトライボタンを表示
                    : _errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!), // エラーメッセージ
                          SizedBox(
                            height: screenHeight * 0.015,
                          ), // スペースをレスポンシブに
                          ElevatedButton(
                            onPressed:
                                _fetchZukanItems, // リトライボタンをタップすると再度データ取得を試みる
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    // ロードが完了し、エラーがなければZukanListContainerを表示
                    : ZukanListContainer(
                      selectedCategory: selectedCategory, // 選択中のカテゴリを渡す
                      filteredItems: filteredItems, // フィルタリングされたアイテムリストを渡す
                      categoryColors: categoryColors, // カテゴリの色情報を渡す
                      allZukanItems:
                          allZukanItems, // お花モデルメッセージのために全てのアイテムリストを渡す
                    ),
          ),
          SizedBox(height: screenHeight * 0.015), // リストコンテナとフッターの間のスペースをレスポンシブに
        ],
      ),
      bottomNavigationBar: const Control(), // アプリケーションのフッターナビゲーションバー
    );
  }
}
