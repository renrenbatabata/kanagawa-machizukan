import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/result_page.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/speech_bubble.dart';
import 'package:frontend/widgets/control.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> uploadImageToPythonServer(
  File imageFile,
  String category,
) async {
  final uri = Uri.parse('http://10.17.7.85:5000/app');

  final request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
  request.fields['category'] = category;

  try {
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);
      print('✅ 分析結果: $result');
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

  const PicturePreviewScreen({
    super.key,
    required this.imagePath,
    required this.category,
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
                    );

                    if (result != null) {
                      final name = result['name'] ?? 'Unknown';
                      final commonName = result['common_names'] ?? 'Unknown';
                      final taxonomy = result['taxonomy'];
                      final description = result['description'];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResultPage(
                                imagePath: imagePath,
                                name: name,
                                commonName: commonName,
                                description: description,
                                taxonomy: taxonomy,
                              ),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder:
                            (_) => const AlertDialog(
                              title: Text("エラー"),
                              content: Text("お花の特定に失敗しました。もう一度お試しください。"),
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
