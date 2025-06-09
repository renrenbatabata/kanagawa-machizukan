// lib/widgets/result_actions.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/take_photo/take_photo_screen.dart';
import 'package:frontend/screens/zukan_page/zukan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/auth_page/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResultActions extends StatelessWidget {
  final String uuid;
  final String category;

  const ResultActions({super.key, required this.uuid, required this.category});

  Future<void> _registerToEncyclopedia(BuildContext context) async {
    final baseUrl = dotenv.env['BASE_API_URL'];
    if (baseUrl == null) {
      _showErrorDialog(context, "APIのURLが設定されていません。");
      return;
    }
    final uri = Uri.parse('$baseUrl/DBAdd');
    final String? userId = AuthService().currentUserId;

    if (userId == null) {
      _showErrorDialog(context, "登録にはログインが必要です。");
      return;
    }

    final dataToSend = {
      'uuid': uuid, // UUIDをMapに入れる
      // 必要であれば 'userId': userId, も含めることを検討
    };
    // 送信するMapの中身を確認

    try {
      // ★★★ ここが重要！http.post を使ってJSONボディを直接送る形に戻す ★★★
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend), // MapをJSON文字列に変換して送信
      );
      print('送信後！$dataToSend');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body); // JSONレスポンスのデコード
        print('✅ 図鑑に登録成功: $responseBody');
        _showSuccessDialog(context, "図鑑に登録しました！");
      } else {
        print('❌ サーバーエラー（登録）: ${response.statusCode}');
        // http.post の場合は response.body でエラーボディが直接取得できる
        print('エラーレスポンスボディ: ${response.body}');
        _showErrorDialog(context, "登録に失敗しました。もう一度お試しください。");
      }
    } catch (e) {
      print('❌ 通信エラー（登録）: $e');
      _showErrorDialog(context, "通信エラーが発生しました。");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("エラー"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("成功"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Zukan()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("ずかんをみる"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => TakePhotoScreen(category: category),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text("もういちどさつえい"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _registerToEncyclopedia(context),
          icon: const Icon(Icons.book),
          label: const Text("ずかんにとうろくする", style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => TakePhotoScreen(category: category),
              ),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.refresh),
          label: const Text("とりなおす", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
