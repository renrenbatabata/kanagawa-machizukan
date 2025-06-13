import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/result_actions.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String hiraganaName;
  final String description;
  final Map<String, dynamic> originalResultData;
  final String category;
  final String? uuid;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.name,
    required this.hiraganaName,
    required this.description,
    required this.originalResultData,
    required this.category,
    this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy年M月d日').format(DateTime.now());
    print(uuid);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Column(
        children: [
          ImageHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // タイトルエリア
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFFFF6E5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      // 名前
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hiraganaName,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  // 写真
                  Center(
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 3),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.file(
                        File(imagePath),
                        width: 350,
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text('発見日: $today', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  // しゃしんをほぞんするボタン
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // 保存処理を書く
                    },
                    icon: const Icon(Icons.download),
                    label: const Text(
                      "しゃしんをほぞんする",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // きほんデータ
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
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                                bottom: Radius.circular(0),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.description, color: Colors.white),
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
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ResultActions(
                    uuid: uuid ?? '',
                    category: category, // カテゴリを指定
                  ),
                  const SizedBox(height: 80), // フッターの余白
                ],
              ),
            ),
          ),
          // フッター
          Control(),
        ],
      ),
    );
  }
}
