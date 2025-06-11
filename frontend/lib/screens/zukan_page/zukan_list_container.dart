import 'package:flutter/material.dart'; // FlutterのUIコンポーネントを使用するために必要
import 'package:frontend/screens/zukan_page/zukan_card.dart'; // ZukanCardウィジェットをインポート（図鑑アイテムの表示に利用）
import 'package:frontend/widgets/colors.dart'; // アプリの色定義（AppColors）をインポート

// ZukanListContainer ウィジェット
// 図鑑リストの全体的なコンテナと、フィルタリングされたアイテムの表示を管理するウィジェットです。
class ZukanListContainer extends StatelessWidget {
  final String selectedCategory; // 現在選択されている図鑑のカテゴリ
  final List<ZukanItem> filteredItems; // 選択されたカテゴリに基づいてフィルタリングされた図鑑アイテムのリスト
  final Map<String, Map<String, Color>> categoryColors; // カテゴリごとの色を定義するマップ
  final List<ZukanItem> allZukanItems; // すべての図鑑アイテムのリスト（「おはな」カテゴリのメッセージ表示判定に利用）

  // コンストラクタ
  const ZukanListContainer({
    super.key,
    required this.selectedCategory,
    required this.filteredItems,
    required this.categoryColors,
    required this.allZukanItems,
  });

  @override
  Widget build(BuildContext context) {
    // 現在選択されているカテゴリに対応するコンテナのメインカラーを取得します。
    // もし色が見つからない場合は、デフォルトでAppColors.orangeを使用します。
    final Color currentContainerColor =
        categoryColors[selectedCategory]?['main'] ?? AppColors.orange;
    // 現在選択されているカテゴリに対応するZukanCardのサブカラーを取得します。
    // もし色が見つからない場合は、デフォルトでAppColors.orangeSubを使用します。
    final Color currentCardColor =
        categoryColors[selectedCategory]?['sub'] ?? AppColors.orangeSub;

    // 「おはな」カテゴリが選択されており、かつ「おはな」カテゴリのアイテムが
    // allZukanItems（全ての図鑑アイテム）の中に一つも存在しない場合にtrueとなるフラグです。
    // このフラグがtrueの場合、「お花を撮影して図鑑に登録しよう！」というメッセージが表示されます。
    final bool showFlowerPromptMessage =
        selectedCategory == "おはな" &&
        !allZukanItems.any(
          (item) =>
              item.category == 'flower', // ZukanItemのcategoryは'flower'であることを想定
        );

    // フィルタリング後のアイテムリスト（filteredItems）が空で、かつ
    // 「お花を撮影して図鑑に登録しよう！」メッセージが表示されない場合にtrueとなるフラグです。
    // このフラグがtrueの場合、「まだ何も発見されていません」というメッセージが表示されます。
    // 「お花」の特定のメッセージが優先されるため、そのメッセージが表示される場合はfalseになります。
    final bool showEmptyStateMessage =
        filteredItems.isEmpty && !showFlowerPromptMessage;

    return Container(
      // コンテナの装飾設定
      decoration: BoxDecoration(
        color: currentContainerColor, // カテゴリに応じた背景色を設定
        borderRadius: const BorderRadius.only(
          // 角の丸み（左上、右上は小さく、左下、右下は大きく丸くする）
          topLeft: Radius.circular(2.0),
          topRight: Radius.circular(2.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
      ),
      child: Column(
        // コンテナ内の要素を縦に並べる
        children: [
          // 条件付き表示: 「お花を撮影して図鑑に登録する」ためのメッセージ表示
          // showFlowerPromptMessageがtrueの場合のみ表示されます。
          if (showFlowerPromptMessage)
            Padding(
              padding: const EdgeInsets.all(20.0), // 全体にパディングを適用
              child: Column(
                // メッセージの内容を縦に並べる
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: AppColors.white,
                  ), // カメラアイコン
                  const SizedBox(height: 10), // スペース
                  Text(
                    '🌸 お花をさつえいして ずかんにとうろくしよう！ 🌸', // メッセージテキスト
                    textAlign: TextAlign.center, // テキストを中央揃えにする
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white, // 文字色
                      fontWeight: FontWeight.bold, // 太字
                    ),
                  ),
                  const SizedBox(height: 10), // スペース
                  Image.asset(
                    'images/kame_pointing_camera.png',
                    height: 100,
                  ), // 亀のイラスト画像
                ],
              ),
            )
          // 条件付き表示: フィルタリングされたアイテムが空の場合のメッセージ表示
          // showEmptyStateMessageがtrueの場合のみ表示されます。（お花メッセージと排他的）
          else if (showEmptyStateMessage)
            Expanded(
              // 親ウィジェットの残りのスペースをすべて占める
              child: Center(
                // 内容を中央に配置
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // 全体にパディングを適用
                  child: Text(
                    selectedCategory == "すべて"
                        ? 'まだ何も発見されていません。\n新しい発見をしてみよう！' // 「すべて」カテゴリでアイテムがない場合
                        : 'このカテゴリにはまだ発見されたアイテムがありません。\n新しい発見をしてみよう！', // 特定カテゴリでアイテムがない場合
                    textAlign: TextAlign.center, // テキストを中央揃えにする
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.white.withOpacity(0.8), // 文字色と透明度
                    ),
                  ),
                ),
              ),
            )
          // 条件付き表示: 図鑑アイテムのリスト表示
          // 上記のどちらのメッセージも表示されない場合に、実際のアイテムリストを表示します。
          else
            Expanded(
              // 親ウィジェットの残りのスペースをすべて占める
              child: ListView.builder(
                // スクロール可能なリストを作成
                padding: const EdgeInsets.only(
                  top: 0.0,
                  bottom: 20.0,
                ), // 上と下のパディング
                itemCount: filteredItems.length, // リストのアイテム数
                itemBuilder: (context, index) {
                  // 各リストアイテム（ZukanCard）の生成
                  return ZukanCard(
                    item: filteredItems[index], // フィルタリングされたリストからZukanItemを渡す
                    cardColor: currentCardColor, // ⭐ カテゴリに応じたカード色をZukanCardに渡す
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
