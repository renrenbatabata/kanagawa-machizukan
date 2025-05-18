import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/flower_result_page.dart';
import 'package:frontend/screens/result_page/result_page.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:frontend/widgets/control.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

Future<Map<String, dynamic>?> uploadImageToPythonServer(
  File imageFile,
  String category,
  Position position,
) async {
  final uri = Uri.parse('http://192.168.3.85:5000/app');

  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  request.fields['category'] = category;
  // 位置情報を送信フィールドに追加
  request.fields['latitude'] = position.latitude.toString();
  request.fields['longitude'] = position.longitude.toString();

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);
      print('✅ 結果: $result');
      return result;
    } else {
      print('❌ サーバーエラー: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ 通信エラー: $e');
  }

  return null;
}

class PicturePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String category;
  final Position position;

  const PicturePreviewScreen({
    super.key,
    required this.imagePath,
    required this.category,
    required this.position,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ヘッダー部分
          const ImageHeader(),

          // 再撮影ボタン
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 20,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.close, color: Colors.white, size: 30),
                  SizedBox(width: 2),
                  Text(
                    "とりなおす",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 画像表示部分
          Expanded(
            child: Center(
              child: ClipOval(
                child: Image.file(
                  File(imagePath),
                  width: 350,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 登録エリア
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Bubble(
                  text: 'ずかんにとうろくしてね！',
                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 20,
                    ),
                  ),
                  onPressed: () async {
                    final file = File(imagePath);

                    final result = await uploadImageToPythonServer(
                      file,
                      category,
                      position,
                    );

                    if (result != null) {
                      if (category == 'flower') {
                        // 花向けのデータを受け取る処理
                        final name = result['name'] ?? 'Unknown'; //名前
                        final family = result['family'] ?? 'Unknown'; //科
                        final genius = result['genius'] ?? "Unlnown"; //〇目
                        final meaning = result['meaning'] ?? "Unlnown"; //花言葉
                        final description = result['description'];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FlowerResultPage(
                                  imagePath: imagePath,
                                  name: name,
                                  family: family,
                                  genius: genius,
                                  meaning: meaning,
                                  description: description,
                                ),
                          ),
                        );
                      } else if (category == 'shrine' || category == 'turtle') {
                        // 神社やかめ向けの処理（仮にこういう構造だとする）
                        final name = result['name'] ?? 'Unknown';
                        final hiraganaName =
                            result['hiraganaName'] ?? "Unkonown";
                        final description =
                            result['description'] ?? 'くわしい情報は見つかりませんでした';
                        final latitude =
                            result['latitude'] != null
                                ? double.tryParse(result['latitude'].toString())
                                : null;
                        final longitude =
                            result['longitude'] != null
                                ? double.tryParse(
                                  result['longitude'].toString(),
                                )
                                : null;

                        if (latitude != null && longitude != null) {
                          // 正しい緯度・経度がある場合
                          print('緯度: $latitude, 経度: $longitude');
                        } else {
                          // 緯度・経度が無効または不明な場合
                          print('緯度または経度が不明です');
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ResultPage(
                                  imagePath: imagePath,
                                  name: name,
                                  hiraganaName: hiraganaName,
                                  description: description,
                                ),
                          ),
                        );
                      } else {
                        // 未対応カテゴリ（念のため）
                        showDialog(
                          context: context,
                          builder:
                              (_) => const AlertDialog(
                                title: Text("エラー"),
                                content: Text("このカテゴリには対応していません。"),
                              ),
                        );
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (_) => const AlertDialog(
                              title: Text("エラー"),
                              content: Text("特定に失敗しました。もう一度お試しください。"),
                            ),
                      );
                    }
                  },

                  icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                  label: const Text(
                    "とうろく",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      // Controlウィジェットを下部ナビゲーションに固定
      bottomNavigationBar: Control(),
    );
  }
}
