// lib/widgets/result_actions.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/take_photo/take_photo_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート

class ResultActions extends StatelessWidget {
  final Map<String, dynamic> resultData; // 結果データ全体を受け取る
  final String imagePath; // 画像のパス
  final String category; // カテゴリ

  const ResultActions({
    super.key,
    required this.resultData,
    required this.imagePath,
    required this.category,
  });

  // 図鑑に登録する関数
  Future<void> _registerToEncyclopedia(BuildContext context) async {
    final uri = Uri.parse(
      'http://10.17.9.86:8080/register_entry',
    ); // 新しいエンドポイント
    final String? userId = AuthService().currentUserId;

    if (userId == null) {
      _showErrorDialog(context, "登録にはログインが必要です。");
      return;
    }

    // 送信するデータを準備
    final Map<String, dynamic> dataToSend = {
      'userId': userId,
      'category': category,
      'imagePath': imagePath, // 画像のパスも保存対象に含める
      ...resultData, // 結果ページのデータを展開して含める
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('✅ 図鑑に登録成功: $responseBody');
        _showSuccessDialog(context, "図鑑に登録しました！");
      } else {
        print('❌ サーバーエラー（登録）: ${response.statusCode}');
        print('エラーレスポンスボディ: ${response.body}');
        _showErrorDialog(context, "登録に失敗しました。もう一度お試しください。");
      }
    } catch (e) {
      print('❌ 通信エラー（登録）: $e');
      _showErrorDialog(context, "通信エラーが発生しました。");
    }
  }

  // エラーダイアログを表示するヘルパー関数
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

  // 成功ダイアログを表示するヘルパー関数
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("成功"),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 図鑑に登録するボタン
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // 登録ボタンの色を青に
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
        // とりなおすボタン
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // とりなおすボタンの色を赤に
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // 撮影ページに遷移
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => TakePhotoScreen(category: category),
              ),
              (Route<dynamic> route) => false, // これで全ての前のルートを削除
            );
          },
          icon: const Icon(Icons.refresh),
          label: const Text("とりなおす", style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
