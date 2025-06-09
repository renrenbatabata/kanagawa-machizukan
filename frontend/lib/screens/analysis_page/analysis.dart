import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/flower_result_page.dart';
import 'package:frontend/screens/result_page/result_page.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:frontend/widgets/control.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //jsonデコード
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/screens/auth_page/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>?> uploadImageToPythonServer(
  File imageFile,
  String category,
  Position position,
  String? address,
  String? userId, // userIdをnull許容にする
) async {
  final baseUrl = dotenv.env['BASE_API_URL'];
  if (baseUrl == null) {
    print('❌ BASE_API_URLが設定されていません。');
    return null;
  }

  final uri = Uri.parse('$baseUrl/analyze'); // APIのエンドポイント
  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  request.fields['category'] = category;

  if (userId != null) {
    request.fields['userId'] = userId;
  } else {
    print('警告: userIdがnullです。ログイン状態を確認してください。');
  }

  // 位置情報を送信フィールドに追加
  request.fields['latitude'] = position.latitude.toString(); //緯度
  request.fields['longitude'] = position.longitude.toString(); //経度

  // 住所情報を送信フィールドに追加
  if (address != null && address.isNotEmpty) {
    request.fields['address'] = address;
  }

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);
      print('✅ 結果: $result');
      return result;
    } else {
      print('❌ サーバーエラー: ${response.statusCode}');
      final errorBody = await response.stream.bytesToString();
      print('エラーレスポンスボディ: $errorBody');
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

          // かいせきボタン
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Bubble(
                  text: 'ずかんにとうろくしてね！',
                  textStyle: TextStyle(fontSize: 20, color: Colors.black),
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

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 20),
                                Text("かいせきちゅう..."), // 解析中メッセージ
                              ],
                            ),
                          ),
                    );

                    final String? userId = AuthService().currentUserId;

                    if (userId == null) {
                      Navigator.pop(context); // ローディングダイアログを閉じる
                      print('エラー: ユーザーIDが取得できませんでした。');
                      showDialog(
                        context: context,
                        builder:
                            (_) => const AlertDialog(
                              title: Text("エラー"),
                              content: Text("登録にはログインが必要です。"),
                            ),
                      );
                      return;
                    }

                    String? detectedAddress;
                    try {
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                            position.latitude,
                            position.longitude,
                            localeIdentifier: "ja_JP", // 日本語の住所を取得
                          );
                      if (placemarks.isNotEmpty) {
                        final p = placemarks.first;
                        detectedAddress =
                            "${p.administrativeArea ?? ''}"
                            "${p.locality ?? ''}"
                            "${p.thoroughfare ?? ''}"
                            "${p.subThoroughfare ?? ''}";
                        print('取得した住所: $detectedAddress');
                      }
                    } catch (e) {
                      print('住所の取得に失敗しました: $e');
                      detectedAddress = null; // 失敗した場合はnullにする
                    }

                    final result = await uploadImageToPythonServer(
                      file,
                      category,
                      position,
                      detectedAddress,
                      userId, // ここで取得したuserIdを渡す
                    );

                    Navigator.pop(context); // ローディングダイアログを閉じる

                    if (result != null) {
                      final uuid = result['uuid'];

                      if (category == 'flower') {
                        print(result['flowersInfo']);
                        final flowersInfo = result['flowersInfo'];
                        final name = flowersInfo['name_jp'] ?? '新発見！！';
                        final family = flowersInfo['family'] ?? '　　　';
                        final genius = flowersInfo['genius'] ?? "　　　";
                        final meaning = flowersInfo['meaning'];
                        final description =
                            flowersInfo['description'] ?? 'くわしい情報は見つかりませんでした';
                        final location =
                            result['location_name'] ??
                            detectedAddress ??
                            '不明な場所';

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
                                  location: location,
                                  category: category,
                                  uuid: uuid,
                                ),
                          ),
                        );
                      } else if (category == 'shrine' || category == 'turtle') {
                        final name = result['name'] ?? '新発見！！';
                        final hiraganaName = result['hiraganaName'] ?? "　　　";
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
                          print('緯度: $latitude, 経度: $longitude');
                        } else {
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
                                  originalResultData: result,
                                  category: category,
                                  uuid: uuid,
                                ),
                          ),
                        );
                      } else {
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
                  icon: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 30,
                  ),
                  label: const Text(
                    "かいせき",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Control(), // constを追加
    );
  }
}
