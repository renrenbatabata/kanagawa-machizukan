import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart';
import 'package:frontend/screens/zukan_page/zukan_detail_page.dart'; // ZukanDetailPageをインポート

class ZukanItem {
  final String id;
  final String name;
  final String? imageUrl;
  final String? discoveredDate;
  final bool isDiscovered;
  final String? hint;
  final String category; // ★追加：カテゴリ情報を保持

  ZukanItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.discoveredDate,
    required this.isDiscovered,
    this.hint,
    required this.category,
  });

  factory ZukanItem.fromJson(Map<String, dynamic> json) {
    return ZukanItem(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      discoveredDate: json['discoveredDate'],
      isDiscovered: json['isDiscovered'],
      hint: json['hint'],
      category: json['category'], // ★追加：JSONからパース
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
  String? _displayedHint;

  // ★追加：_fetchHint 関数をここに定義します
  Future<String> _fetchHint(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // API遅延をシミュレート
    // ここでitemIdに基づいて適切なヒントを返します
    if (itemId == 'sugiyama1') {
      return '神奈川区で最も古い神社の一つです。';
    } else if (itemId == 'kame_mystery') {
      return '公園に隠れているカメだよ。';
    } else if (itemId == 'jindaiji') {
      return '鎌倉時代から続く古社で、広大な公園が隣接しています。';
    } else if (itemId == 'sugiyama2') {
      return '高台にある静かな神社だよ。';
    } else if (itemId == 'kame_park') {
      return '三ツ沢公園で子どもたちと遊んでいるよ。';
    } else if (itemId == 'flower_sakura') {
      return '春に咲く代表的な花だよ。';
    } else if (itemId == 'flower_himawari') {
      return '夏に太陽に向かって咲く大きな花だよ。';
    }
    return 'ヒントはありません。';
  }

  // 仮のAPI呼び出し関数 (実際はJavaバックエンドとの通信に置き換える)
  Future<Map<String, dynamic>> _fetchDetails(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 700)); // API遅延をシミュレート
    // バックエンドから取得する詳細情報に hiraganaName や location を追加
    if (itemId == 'sugiyama1') {
      return {
        'id': itemId,
        'name': '杉山神社',
        'hiraganaName': 'すぎやまじんじゃ', // ★追加
        'description':
            '横浜市内最古の歴史を持つといわれる「杉山神社」の一社で、神奈川区の総鎮守として地域住民に親しまれています。区役所の裏手の高台に位置し、静かで厳かな雰囲気です。例大祭では多くの人で賑わいます。',
        'location': '神奈川区広台太田町', // ★追加
        'imageUrl': 'images/sugiyama_jinja.jpg', // 仮の画像パス
        'discoveredDate': '2025年5月5日', // 詳細ページで表示するために必要なら追加
      };
    } else if (itemId == 'jindaiji') {
      return {
        'id': itemId,
        'name': '神大寺神明社',
        'hiraganaName': 'じんだいじしんめいしゃ',
        'description':
            '地域名にもなっている古社で、創建は鎌倉時代とも伝えられています。広々とした境内で、地域住民の信仰を集めています。隣接して広大な公園があり、散策にも適しています。',
        'location': '神奈川区神大寺',
        'imageUrl': 'images/jindaiji_jinja.jpg',
        'discoveredDate': '2025年5月10日',
      };
    } else if (itemId == 'kame_park') {
      return {
        'id': itemId,
        'name': '公園のカメ太郎オブジェ',
        'hiraganaName': 'こうえんのかめたろうおぶじぇ',
        'description':
            '神奈川区のあちこちに隠れている、区のキャラクター「かめ太郎」のオブジェの一つだよ。公園で子どもたちと遊んでいるかも？',
        'location': '三ツ沢公園',
        'imageUrl': 'images/kame_park.jpg',
        'discoveredDate': '2025年5月15日',
      };
    } else if (itemId == 'flower_sakura') {
      return {
        'id': itemId,
        'name': 'サクラ',
        'hiraganaName': 'さくら',
        'description': '日本を代表する花で、春に美しいピンク色の花を咲かせます。お花見の季節には多くの人を魅了します。',
        'location': '区内各地',
        'imageUrl': 'images/flower_sakura.jpg',
        'discoveredDate': '2025年4月1日',
      };
    } else if (itemId == 'flower_himawari') {
      return {
        'id': itemId,
        'name': 'ヒマワリ',
        'hiraganaName': 'ひまわり',
        'description': '夏を代表する花で、太陽に向かって大きく咲く黄色い花が特徴です。元気をもらえる花として親しまれています。',
        'location': '畑や公園',
        'imageUrl': 'images/flower_himawari.jpg',
        'discoveredDate': '2025年7月20日', // 例として
      };
    }
    return {
      'id': itemId,
      'name': '不明なアイテム',
      'hiraganaName': '',
      'description': '情報が見つかりませんでした。',
      'location': '',
      'imageUrl': null,
      'discoveredDate': '',
    };
  }

  void _showDetailsPage(BuildContext context, Map<String, dynamic> details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ZukanDetailPage(
              details: details,
              capturedImagePath: details['imageUrl'], // 例: バックエンドが公式画像URLを返した場合
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
          // 発見済みの場合、詳細情報を取得して詳細ページへ遷移
          final details = await _fetchDetails(widget.item.id);
          _showDetailsPage(context, details);
        } else if (showCallToAction) {
          // ここで showCallToAction をチェック
          // 「撮影して図鑑に登録しよう！」の場合、何もしないか、カメラ起動などのアクションを促す
          print('カメラ起動を促すアクション'); // デバッグ用
        } else if (!widget.item.isDiscovered && _displayedHint == null) {
          // 未発見かつヒント未表示の場合、ヒントを取得して表示
          setState(() {
            _displayedHint = 'ヒントを取得中...'; // ローディング表示
          });
          String hint = await _fetchHint(widget.item.id);
          setState(() {
            _displayedHint = hint;
          });
        } else if (!widget.item.isDiscovered && _displayedHint != null) {
          // 未発見でヒント表示中の場合、何もしない（あるいはヒントを再度非表示にするなどの処理）
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
                  showCallToAction
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'images/camera_placeholder.png', // カメラアイコンや特別な画像を配置
                          fit: BoxFit.cover,
                        ),
                      )
                      : widget.item.isDiscovered
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
                    showCallToAction
                        ? '撮影して図鑑に登録しよう！'
                        : widget.item.isDiscovered
                        ? widget.item.name
                        : (_displayedHint ?? '??????'), // ヒント表示中か未発見か
                    style: TextStyle(
                      fontSize: showCallToAction ? 16 : 18, // テキストサイズを調整
                      fontWeight: FontWeight.bold,
                      color:
                          showCallToAction
                              ? AppColors
                                  .blue // 目を引く色に
                              : widget.item.isDiscovered ||
                                  _displayedHint != null
                              ? Colors.black87
                              : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  if (!showCallToAction) // 「撮影して図鑑に登録しよう」の場合は表示しない
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
