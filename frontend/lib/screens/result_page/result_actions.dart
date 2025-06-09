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
    };
    print('送信するデータ: $dataToSend'); // 送信するMapの中身を確認

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend), // MapをJSON文字列に変換して送信
      );

      // ★★★ ここからが変更箇所です ★★★
      if (response.statusCode == 200) {
        // サーバーからのレスポンスボディを文字列として取得
        final responseBody = response.body;
        print('✅ サーバーレスポンスボディ: $responseBody');

        // レスポンスボディが "処理完了" であるかをチェック
        if (responseBody == "処理完了") {
          print('✅ 図鑑に登録成功');
          _showSuccessDialog(context, "図鑑に登録しました！");
        } else {
          // 200 OKだけど "処理完了" ではない場合
          print('⚠️ 登録は成功しましたが、予期しないレスポンスボディです: $responseBody');
          _showErrorDialog(context, "登録に成功しましたが、予期しないレスポンスがありました。");
        }
      } else if (response.statusCode == 400) {
        // 400 Bad Request の場合
        final errorBody = response.body;
        print('❌ サーバーエラー（登録 - Bad Request）: ${response.statusCode}');
        print('エラーレスポンスボディ: $errorBody');
        // エラーボディが "error" であるかをチェック
        if (errorBody == "error") {
          _showErrorDialog(context, "登録に失敗しました。無効なリクエストです。");
        } else {
          _showErrorDialog(
            context,
            "登録に失敗しました。（エラーコード: ${response.statusCode}）",
          );
        }
      } else {
        // その他のステータスコードの場合
        print('❌ サーバーエラー（登録）: ${response.statusCode}');
        print('エラーレスポンスボディ: ${response.body}');
        _showErrorDialog(context, "登録に失敗しました。（エラーコード: ${response.statusCode}）");
      }
      // ★★★ ここまでが変更箇所です ★★★
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
