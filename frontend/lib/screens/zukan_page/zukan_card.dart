import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート

// 仮のZukanItemモデル
// バックエンドからのレスポンスを想定したデータ構造
class ZukanItem {
  final String id;
  final String name;
  final String? imageUrl; // 発見済みの場合のみ
  final String? discoveredDate; // 発見済みの場合のみ
  final bool isDiscovered;
  final String? hint; // 未発見の場合のみ

  ZukanItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.discoveredDate,
    required this.isDiscovered,
    this.hint,
  });

  // バックエンドからのJSONをZukanItemに変換するファクトリコンストラクタ
  factory ZukanItem.fromJson(Map<String, dynamic> json) {
    return ZukanItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      discoveredDate: json['discoveredDate'],
      isDiscovered: json['isDiscovered'],
      hint: json['hint'],
    );
  }
}

class ZukanCard extends StatefulWidget {
  final ZukanItem item;
  final Color cardColor; // カードの背景色を受け取る

  const ZukanCard({Key? key, required this.item, required this.cardColor})
    : super(key: key);

  @override
  State<ZukanCard> createState() => _ZukanCardState();
}

class _ZukanCardState extends State<ZukanCard> {
  String? _displayedHint; // 未発見カードでヒントが表示されているか管理

  // 仮のAPI呼び出し関数 (実際はJavaバックエンドとの通信に置き換える)
  Future<String> _fetchHint(String itemId) async {
    // ここでJavaバックエンドAPIを呼び出し、ヒントを取得します
    // 例: Dioやhttpパッケージを使用
    // final response = await Dio().get('YOUR_JAVA_API_ENDPOINT/hints/$itemId');
    // return response.data['hint'];

    // デモ用のダミーデータ
    await Future.delayed(const Duration(milliseconds: 500)); // API遅延をシミュレート
    switch (itemId) {
      case 'sugiyama1':
        return '区役所に近い高台にある、神奈川区の総鎮守だよ。';
      case 'jindaiji':
        return '神大寺という地名にもなっている、昔からある大きな神社だよ。';
      case 'kame_mystery':
        return '横浜駅近くの公園の、池のほとりに隠れているかも！';
      default:
        return 'ヒントは見つかりませんでした。';
    }
  }

  // 仮のAPI呼び出し関数 (実際はJavaバックエンドとの通信に置き換える)
  Future<Map<String, dynamic>> _fetchDetails(String itemId) async {
    // ここでJavaバックエンドAPIを呼び出し、詳細情報を取得します
    // 例: Dioやhttpパッケージを使用
    // final response = await Dio().get('YOUR_JAVA_API_ENDPOINT/details/$itemId');
    // return response.data;

    // デモ用のダミーデータ
    await Future.delayed(const Duration(milliseconds: 700)); // API遅延をシミュレート
    return {
      'id': itemId,
      'name': '杉山神社',
      'description':
          '横浜市内最古の歴史を持つといわれる「杉山神社」の一社で、神奈川区の総鎮守として地域住民に親しまれています。区役所の裏手の高台に位置し、静かで厳かな雰囲気です。例大祭では多くの人で賑わいます。',
      'location': '神奈川区広台太田町',
      'imageUrl': 'images/sugiyama_jinja.jpg', // 仮の画像パス
    };
  }

  void _showDetailsPage(BuildContext context, Map<String, dynamic> details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZukanDetailPage(details: details),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.item.isDiscovered && _displayedHint == null) {
          // 未発見かつヒント未表示の場合、ヒントを取得して表示
          setState(() {
            _displayedHint = 'ヒントを取得中...'; // ローディング表示
          });
          String hint = await _fetchHint(widget.item.id);
          setState(() {
            _displayedHint = hint;
          });
        } else if (widget.item.isDiscovered) {
          // 発見済みの場合、詳細情報を取得して詳細ページへ遷移
          final details = await _fetchDetails(widget.item.id);
          _showDetailsPage(context, details);
        } else if (!widget.item.isDiscovered && _displayedHint != null) {
          // 未発見でヒント表示中の場合、何もしないか、あるいはヒントを再度非表示にするなどの処理
          // 今回はシンプルに何もしない
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 10.0,
        ), // カード間の余白
        decoration: BoxDecoration(
          color: widget.cardColor, // 親から受け取った色を使用
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // 画像表示部分
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[200], // 画像がない場合のプレースホルダー色
                borderRadius: BorderRadius.circular(10.0),
              ),
              child:
                  widget.item.isDiscovered
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          widget.item.imageUrl ??
                              'images/placeholder.png', // 画像がなければプレースホルダー
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                      : Center(
                        child: Icon(
                          Icons.help_outline, // 未発見を示すアイコン
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
            const SizedBox(width: 15.0),
            // 情報表示部分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.isDiscovered
                        ? widget.item.name
                        : (_displayedHint ?? '??????'), // ヒント表示中か未発見か
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          widget.item.isDiscovered || _displayedHint != null
                              ? Colors.black87
                              : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    widget.item.isDiscovered
                        ? '発見日: ${widget.item.discoveredDate}'
                        : (_displayedHint == null
                            ? 'タップしてヒントを見る'
                            : ''), // ヒント表示中の場合は空文字
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          widget.item.isDiscovered
                              ? Colors.black54
                              : Colors.grey[600],
                    ),
                  ),
                  if (!widget.item.isDiscovered &&
                      _displayedHint != null &&
                      _displayedHint != 'ヒントを取得中...')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _displayedHint!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  if (!widget.item.isDiscovered &&
                      _displayedHint == 'ヒントを取得中...')
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        color: AppColors.blue, // プログレスバーの色を調整
                        backgroundColor: AppColors.blueSub,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 詳細ページ (簡単なプレースホルダー)
class ZukanDetailPage extends StatelessWidget {
  final Map<String, dynamic> details;

  const ZukanDetailPage({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details['name']),
        backgroundColor: AppColors.green, // アプリのテーマカラーに合わせる
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            details['imageUrl'] != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(details['imageUrl'], fit: BoxFit.cover),
                )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Text(
              details['name'],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '場所: ${details['location']}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              details['description'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            // ここに関連情報、アクセス、イベントなどを追加
          ],
        ),
      ),
    );
  }
}
