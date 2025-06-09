import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart';
import 'package:frontend/screens/zukan_page/zukan_detail_page.dart';
import 'dart:convert'; // base64Decodeのために追加
import 'package:http/http.dart' as http; // httpパッケージをインポート
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .envファイルから環境変数を読み込むため
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート

class ZukanItem {
  final int id; // ⭐ int 型
  final String category;
  final String name;
  final String? shootingLocation;
  final String? rawImageData; // Base64エンコードされた画像データ
  final String? discoveredDate;
  final bool isDiscovered;
  final String? hint;
  final String? imageUrl; // アプリ内アセットURLなど、rawImageDataとは別の画像URL

  ZukanItem({
    required this.id,
    required this.category,
    required this.name,
    this.shootingLocation,
    this.rawImageData,
    this.discoveredDate,
    required this.isDiscovered,
    this.hint,
    this.imageUrl,
  });

  factory ZukanItem.fromJson(Map<String, dynamic> json) {
    return ZukanItem(
      id: json['id'] as int, // ⭐ ここを int にキャスト
      category: json['category'] as String,
      name: json['name'] as String,
      shootingLocation: json['shootingLocation'] as String?,
      rawImageData: json['imageData'] as String?,
      discoveredDate: json['discoveredDate'] as String?,
      isDiscovered: json['isDiscovered'] as bool? ?? false,
      hint: json['hint'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class ZukanCard extends StatefulWidget {
  final ZukanItem item;
  final Color cardColor;

  const ZukanCard({
    super.key,
    required this.item,
    required this.cardColor,
  }); // super.keyを使用

  @override
  State<ZukanCard> createState() => _ZukanCardState();
}

class _ZukanCardState extends State<ZukanCard> {
  String? _displayedHint;

  // Base64データのプレフィックスを除去する関数
  String _stripBase64Prefix(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    return base64String.replaceFirst(regex, '');
  }

  @override
  void initState() {
    super.initState();
    print('--- ZukanCard Debug - Item ID: ${widget.item.id} ---');
    print('  Category: ${widget.item.category}');
    print('  Name: ${widget.item.name}');
    print('  Is Discovered: ${widget.item.isDiscovered}');
    print('  Discovered Date: ${widget.item.discoveredDate}');
    print('  Shooting Location: ${widget.item.shootingLocation}');
    print('  Raw Image Data (present): ${widget.item.rawImageData != null}');
    if (widget.item.rawImageData != null) {
      print(
        '  Raw Image Data (start): ${widget.item.rawImageData!.substring(0, (widget.item.rawImageData!.length > 50 ? 50 : widget.item.rawImageData!.length))}...',
      );
    }
    print('  Image URL: ${widget.item.imageUrl}');
    print('  Hint: ${widget.item.hint}');
    print('--- End ZukanCard Debug ---');
  }

  // --- ⭐ _fetchHint の引数を int に修正 ⭐ ---
  Future<String> _fetchHint(int itemId) async {
    final baseUrl = dotenv.env['BASE_API_URL'];
    final userId = AuthService().currentUserId;

    if (baseUrl == null) {
      print('❌ エラー: BASE_API_URLが設定されていません。');
      return 'ヒントの取得に失敗しました (設定エラー)。';
    }
    if (userId == null) {
      print('❌ エラー: ユーザーIDが取得できません。ヒントの取得にはログインが必要です。');
      return 'ヒントの取得に失敗しました (未ログイン)。';
    }

    final uri = Uri.parse('$baseUrl/zukan/item/hint').replace(
      queryParameters: {
        'userId': userId,
        'itemId': itemId.toString(), // intをStringに変換して送信
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody['hintText'] as String? ?? 'ヒントが見つかりませんでした。';
      } else {
        print('❌ ヒント取得サーバーエラー: ${response.statusCode}');
        print('エラーレスポンスボディ (ヒント): ${response.body}');
        return 'ヒントの取得に失敗しました (エラーコード: ${response.statusCode})。';
      }
    } catch (e) {
      print('❌ ヒント取得通信エラー: $e');
      return 'ヒントの取得に失敗しました (通信エラー)。';
    }
  }

  // --- ⭐ _fetchDetails の引数を int に修正 ⭐ ---
  Future<Map<String, dynamic>> _fetchDetails(int itemId) async {
    final baseUrl = dotenv.env['BASE_API_URL'];
    final userId = AuthService().currentUserId;

    if (baseUrl == null) {
      print('❌ エラー: BASE_API_URLが設定されていません。');
      return {'error': '設定エラー'};
    }
    if (userId == null) {
      print('❌ エラー: ユーザーIDが取得できません。詳細の取得にはログインが必要です。');
      return {'error': '未ログイン'};
    }

    final uri = Uri.parse('$baseUrl/zukan/item/details').replace(
      queryParameters: {
        'userId': userId,
        'itemId': itemId.toString(), // intをStringに変換して送信
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        print('✅ 詳細データ取得成功: $result');
        return result;
      } else {
        print('❌ 詳細取得サーバーエラー: ${response.statusCode}');
        print('エラーレスポンスボディ (詳細): ${response.body}');
        return {'error': 'サーバーエラー', 'statusCode': response.statusCode};
      }
    } catch (e) {
      print('❌ 詳細取得通信エラー: $e');
      return {'error': '通信エラー', 'exception': e.toString()};
    }
  }

  void _showDetailsPage(BuildContext context, Map<String, dynamic> details) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZukanDetailPage(
              details: details,
              capturedImagePath:
                  details['rawImageData'] != null
                      ? 'data:image/jpeg;base64,${_stripBase64Prefix(details['rawImageData'] as String)}'
                      : details['imageUrl'] as String?,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFlowerCategory = widget.item.category == 'flower';
    final bool showCallToAction = isFlowerCategory && !widget.item.isDiscovered;

    return GestureDetector(
      onTap: () async {
        if (widget.item.isDiscovered) {
          final details = await _fetchDetails(widget.item.id); // ⭐ int型を直接渡す
          _showDetailsPage(context, details);
        } else if (showCallToAction) {
          print('カメラ起動を促すアクション');
          // ここでカメラ起動のロジックや、カメラページへの遷移などを実装します。
          // 例: Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(category: 'flower')));
        } else if (!widget.item.isDiscovered && _displayedHint == null) {
          setState(() {
            _displayedHint = 'ヒントを取得中...';
          });
          String hint = await _fetchHint(widget.item.id); // ⭐ int型を直接渡す
          setState(() {
            _displayedHint = hint;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: widget.cardColor,
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
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child:
                  showCallToAction
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'images/camera_placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      )
                      : widget.item.isDiscovered
                      ? (widget.item.rawImageData != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.memory(
                              base64Decode(
                                _stripBase64Prefix(widget.item.rawImageData!),
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  'Error loading image from Base64: $error',
                                );
                                return const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                          : widget.item.imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              widget.item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading network image: $error');
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
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          ))
                      : Center(
                        child: Icon(
                          Icons.help_outline,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showCallToAction
                        ? '撮影して図鑑に登録しよう！'
                        : widget.item.isDiscovered
                        ? widget.item.name
                        : (_displayedHint ?? '??????'),
                    style: TextStyle(
                      fontSize: showCallToAction ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          showCallToAction
                              ? AppColors.blue
                              : widget.item.isDiscovered ||
                                  _displayedHint != null
                              ? Colors.black87
                              : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  if (!showCallToAction)
                    Text(
                      widget.item.isDiscovered
                          ? '発見日: ${widget.item.discoveredDate}'
                          : (_displayedHint == null ? 'タップしてヒントを見る' : ''),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            widget.item.isDiscovered
                                ? Colors.black54
                                : Colors.grey[600],
                      ),
                    ),
                  if (!widget.item.isDiscovered &&
                      _displayedHint == 'ヒントを取得中...')
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(
                        color: AppColors.blue,
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
