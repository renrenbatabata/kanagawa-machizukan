import 'package:flutter/material.dart'; // FlutterのUIコンポーネントを使用するために必要
import 'package:frontend/screens/zukan_page/zukan_detail_page.dart'; // 図鑑の詳細ページへ遷移するためにインポート
import 'dart:convert'; // Base64エンコードのために追加
import 'package:http/http.dart' as http; // httpパッケージをインポート
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .envファイルから環境変数を読み込むため
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート

// ZukanItem クラス
// 図鑑アイテムのデータを保持するためのモデルクラスです。
class ZukanItem {
  final int id; // アイテムの一意なID
  final String category; // アイテムのカテゴリ（例: 'flower', 'insect'）
  final String name; // アイテムの名前
  final String? shootingLocation; // 場所
  final String? shootingDate; // ⭐ 修正: 発見日時をString?に戻す
  final String? rawImageData; // Base64エンコードされた画像データ

  // コンストラクタ
  ZukanItem({
    required this.id,
    required this.category,
    required this.name,
    this.shootingLocation,
    this.rawImageData,
    this.shootingDate,
  });

  // JSONデータからZukanItemオブジェクトを生成するためのファクトリコンストラクタ
  factory ZukanItem.fromJson(Map<String, dynamic> json) {
    return ZukanItem(
      id: json['id'] as int,
      category: json['category'] as String,
      name: json['name'] as String,
      shootingLocation: json['shootingLocation'] as String?,
      rawImageData: json['imageData'] as String?,
      shootingDate: json['shootingDate'] as String?, // ⭐ 修正: String?として受け取る
    );
  }
}

// ZukanCard ウィジェット
// 各図鑑アイテムを表示するためのカード型ウィジェットです。
class ZukanCard extends StatefulWidget {
  final ZukanItem item; // 表示する図鑑アイテムのデータ
  final Color cardColor; // カードの背景色

  const ZukanCard({super.key, required this.item, required this.cardColor});

  @override
  State<ZukanCard> createState() => _ZukanCardState();
}

// _ZukanCardState クラス
// ZukanCard ウィジェットの状態を管理するクラスです。
class _ZukanCardState extends State<ZukanCard> {
  // Base64データのプレフィックスを除去する関数
  String _stripBase64Prefix(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    return base64String.replaceFirst(regex, '');
  }

  // ⭐ 新規追加: 日付文字列をYYYY年MM月DD日形式に整形するヘルパー関数
  String _formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '不明'; // 文字列がnullまたは空の場合は'不明'を返す
    }
    try {
      // "2025-06-04T00:00" の形式をDateTimeオブジェクトにパース
      final dateTime = DateTime.parse(dateString);

      // 年、月、日を取得し、2桁にゼロ埋め
      final year = dateTime.year.toString();
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');

      return '${year}年${month}月${day}日'; // YYYY年MM月DD日形式で返す
    } catch (e) {
      print('日付の整形エラー: $e, データ: $dateString');
      return '不正な日付'; // 変換中にエラーが発生した場合は'不正な日付'を返す
    }
  }

  @override
  void initState() {
    super.initState();
    // ウィジェットの初期化時に、デバッグ情報をコンソールに出力します。
    print('--- ZukanCard Debug - Item ID: ${widget.item.id} ---');
    print('   Category: ${widget.item.category}');
    print('   Name: ${widget.item.name}');
    print('   Discovered Date: ${widget.item.shootingDate}'); // ここはまだ未整形文字列のまま
    print('   Shooting Location: ${widget.item.shootingLocation}');
    print('   Raw Image Data (present): ${widget.item.rawImageData != null}');
    if (widget.item.rawImageData != null) {
      print(
        '   Raw Image Data (start): ${widget.item.rawImageData!.substring(0, (widget.item.rawImageData!.length > 50 ? 50 : widget.item.rawImageData!.length))}...',
      );
    }
    print('--- End ZukanCard Debug ---');
  }

  // 特定の図鑑アイテムの詳細データをサーバーから非同期で取得する関数です。
  Future<Map<String, dynamic>> _fetchDetails(int itemId) async {
    final baseUrl = dotenv.env['BASE_API_URL']; // .envファイルからAPIのベースURLを取得
    final userId = AuthService().currentUserId; // 認証サービスから現在のユーザーIDを取得

    // 環境変数またはユーザーIDが取得できない場合のエラーハンドリング
    if (baseUrl == null) {
      print('❌ エラー: BASE_API_URLが設定されていません。');
      return {'error': '設定エラー'};
    }
    if (userId == null) {
      print('❌ エラー: ユーザーIDが取得できません。詳細の取得にはログインが必要です。');
      return {'error': '未ログイン'};
    }

    // APIリクエストのURIを構築
    final uri = Uri.parse('$baseUrl/zukan/item/details').replace(
      queryParameters: {
        'userId': userId, // ユーザーIDをクエリパラメータとして追加
        'itemId': itemId.toString(), // intをStringに変換して送信
      },
    );

    try {
      // HTTP POSTリクエストを送信 (APIの仕様に合わせてGET/POSTを調整してください)
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        // ステータスコードが200（成功）の場合、レスポンスボディをJSONとしてデコード
        // レスポンスがリスト形式で返ってくることを想定して、リストとしてデコード
        final List<dynamic> jsonResponseList = json.decode(response.body);

        if (jsonResponseList.isNotEmpty) {
          // リストが空でない場合、最初の要素をMapとして取得し、返却
          final Map<String, dynamic> result =
              jsonResponseList.first as Map<String, dynamic>;
          print('✅ 詳細データ取得成功: $result');
          return result;
        } else {
          // リストが空の場合の処理
          print('⚠️ 詳細データが空のリストで返されました。');
          return {'error': '詳細データが見つかりません。'};
        }
      } else {
        // サーバーエラーの場合の処理
        print('❌ 詳細取得サーバーエラー: ${response.statusCode}');
        print('エラーレスポンスボディ (詳細): ${response.body}');
        return {'error': 'サーバーエラー', 'statusCode': response.statusCode};
      }
    } catch (e) {
      // 通信エラー（ネットワーク接続など）の場合の処理
      print('❌ 詳細取得通信エラー: $e');
      return {'error': '通信エラー', 'exception': e.toString()};
    }
  }

  // 詳細ページを表示するための関数です。
  // サーバーから取得した詳細データを受け取り、ZukanDetailPageへ遷移します。
  void _showDetailsPage(BuildContext context, Map<String, dynamic> details) {
    // 取得したデータにエラーが含まれている場合、エラーダイアログを表示
    if (details.containsKey('error')) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("エラー"),
              content: Text("詳細情報の取得に失敗しました: ${details['error']}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    // エラーがなければ、ZukanDetailPageへ遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZukanDetailPage(
              details: details, // 取得した詳細データを渡す
              // Base64画像データが存在する場合、プレフィックスを付けて渡す
              capturedImagePath:
                  details['rawImageData'] != null
                      ? 'data:image/jpeg;base64,${_stripBase64Prefix(details['rawImageData'] as String)}'
                      : null,
            ),
      ),
      // capturedImagePath は ZukanCard から ZukanDetailPage へ画像データを渡すために使用されます。
      // ZukanDetailPage でこのパスを使って画像を表示します。
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // カードがタップされた際の処理
      onTap: () async {
        // 常に詳細データを非同期で取得し、詳細ページを表示します。
        final details = await _fetchDetails(widget.item.id);
        _showDetailsPage(context, details);
      },
      child: Container(
        // カード全体のコンテナ
        width: double.infinity, // 横幅を最大にする
        padding: const EdgeInsets.all(12.0), // 内側のパディング
        margin: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 10.0,
        ), // 外側のマージン
        decoration: BoxDecoration(
          color: widget.cardColor, // カードの背景色
          borderRadius: BorderRadius.circular(15.0), // 角を丸くする
          boxShadow: [
            // カードの影
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 影の色と透明度
              spreadRadius: 1, // 影の広がり
              blurRadius: 5, // 影のぼかし
              offset: const Offset(0, 3), // 影のオフセット
            ),
          ],
        ),
        child: Row(
          // カード内の要素を横並びにする
          children: [
            // 画像表示部分のコンテナ
            Container(
              width: 90, // 幅
              height: 90, // 高さ
              decoration: BoxDecoration(
                color: Colors.grey[200], // 背景色
                borderRadius: BorderRadius.circular(10.0), // 角を丸くする
              ),
              child:
                  widget.item.rawImageData != null
                      // rawImageData が存在する場合、Base64画像をデコードして表示
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.memory(
                          base64Decode(
                            _stripBase64Prefix(widget.item.rawImageData!),
                          ),
                          fit: BoxFit.cover, // 画像のフィット方法
                          // 画像の読み込みに失敗した場合のエラーハンドリング
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image from Base64: $error');
                            return const Icon(
                              Icons.broken_image, // エラーアイコンを表示
                              size: 50,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                      // rawImageData が存在しない場合、代替アイコンを表示
                      : Center(
                        child: Icon(
                          Icons.image_not_supported, // 画像なしアイコンを表示
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
            const SizedBox(width: 15.0), // 画像とテキストの間のスペース
            // 情報表示部分（アイテム名、発見日、場所）
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 左寄せにする
                children: [
                  Text(
                    widget.item.name, // アイテム名を表示
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5.0), // アイテム名と発見日の間のスペース
                  Text(
                    // ⭐ 修正: _formatDateString関数を使って日付を整形して表示
                    '発見日: ${_formatDateString(widget.item.shootingDate)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    '場所: ${widget.item.shootingLocation ?? '不明'}', // 発見場所を表示（データがない場合は'不明'）
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
