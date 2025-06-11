import 'dart:convert'; // base64Decodeを使うために必要
import 'dart:typed_data'; // Uint8Listを使うために必要
import 'package:flutter/material.dart';
import 'package:frontend/widgets/back_button.dart';
import 'package:frontend/widgets/header.dart'; // ImageHeaderをインポート
import 'package:frontend/widgets/control.dart'; // Controlをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート
// 以下のインポートはZukanDetailPageでは不要なので削除します
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

class ZukanDetailPage extends StatelessWidget {
  final Map<String, dynamic> details;
  // capturedImagePath はZukanCardでBase64データURL（例: 'data:image/jpeg;base64,...'）形式で渡されることを想定
  final String? capturedImagePath;

  const ZukanDetailPage({
    // コンストラクタをconstに修正
    Key? key,
    required this.details,
    this.capturedImagePath, // オプショナル引数として追加
  }) : super(key: key);

  // --- ヘルパー関数 ---

  // Base64データのプレフィックスを除去する関数
  String _stripBase64Prefix(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    return base64String.replaceFirst(regex, '');
  }

  // Base64データURLをUint8Listにデコードするヘルパー関数
  Uint8List? _decodeBase64Image(String? base64DataUrl) {
    if (base64DataUrl == null || base64DataUrl.isEmpty) {
      return null;
    }
    try {
      final String strippedBase64 = _stripBase64Prefix(base64DataUrl);
      return base64Decode(strippedBase64);
    } catch (e) {
      print('Base64画像のデコードエラー: $e');
      return null;
    }
  }

  // 日付文字列をYYYY年MM月DD日形式に整形するヘルパー関数
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

      return '${year}年${month}月${day}日'; //YYYY年MM月DD日形式で返す
    } catch (e) {
      print('日付の整形エラー: $e, データ: $dateString');
      return '不正な日付'; // 変換中にエラーが発生した場合は'不正な日付'を返す
    }
  }

  // --- /ヘルパー関数 ---

  @override
  Widget build(BuildContext context) {
    // 詳細情報から名前、読み仮名、説明、場所、発見日を取得
    // itemId はこのページで直接APIを叩かないため、ここでは使用しません。
    // final String itemId = details['id']?.toString() ?? '不明';
    final String name = details['name'] ?? '名前がありません';
    final String hiraganaName = details['hiraganaName'] ?? '';
    final String description = details['description'] ?? '詳しい説明はありません。';

    // ZukanCardから渡されるキーに合わせる
    final String shootingDate = details['shootingDate'] ?? ''; // 発見日
    final String address = details['address'] ?? '場所不明'; // 場所
    final String? rawImageDataFromDetails =
        details['rawImageData']; // ZukanItemのrawImageData

    // 分類と花言葉をdetailsから取得
    final String family = details['family'] ?? ''; // 科名
    final String genius = details['genius'] ?? ''; // 属名
    final String? meaning = details['meaning']; // 花言葉

    // capturedImagePath があればそれを優先的にデコード
    // なければ rawImageDataFromDetails をデコード
    final Uint8List? imageBytesToDisplay =
        _decodeBase64Image(capturedImagePath) ??
        _decodeBase64Image(rawImageDataFromDetails);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Column(
        children: [
          const ImageHeader(), // 共通ヘッダー
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // 子要素を水平方向に引き伸ばす
                children: [
                  const SizedBox(height: 30),

                  // 名前と読み仮名、戻るボタンのセクション
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // 両端に配置
                      crossAxisAlignment: CrossAxisAlignment.start, // 上揃え
                      children: [
                        Expanded(
                          // 名前と読み仮名が長い場合に対応
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (hiraganaName.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  hiraganaName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 20.0), // 名前とボタンの間のスペース
                        const Align(
                          alignment: Alignment.topRight, // 右上に配置
                          child: CustomBackButton(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 写真（表示する画像があればそれを表示、なければ代替アイコン）
                  Center(
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.orange,
                          width: 4,
                        ), // オレンジの縁取り
                        boxShadow: [
                          // 少し影をつける
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge, // 角丸に画像をクリップ
                      child:
                          imageBytesToDisplay != null
                              ? Image.memory(
                                imageBytesToDisplay,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image bytes: $error');
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                              : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (shootingDate.isNotEmpty)
                    Text(
                      '発見日: ${_formatDateString(shootingDate)}', // 日付を整形して表示
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 「きほんデータ」セクション
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 8,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  "きほんデータ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromARGB(161, 251, 215, 148),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ⭐ 分類（科・属）を表示
                              if (family.isNotEmpty || genius.isNotEmpty)
                                Text(
                                  "分類 : $family ${genius.isNotEmpty ? genius : ''}", // 属があれば表示
                                  style: const TextStyle(fontSize: 20),
                                ),
                              const SizedBox(height: 8),
                              // ⭐ 花言葉を表示
                              if (meaning != null && meaning.isNotEmpty)
                                Text(
                                  "花言葉 :$meaning",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              if (address.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    "場所: $address",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40), // フッターとの間の余白
                ],
              ),
            ),
          ),
          const Control(), // 共通フッター
        ],
      ),
    );
  }
}
