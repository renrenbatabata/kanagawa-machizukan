import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/header.dart';

class ResultPage extends StatelessWidget {
  final String imagePath;
  final String name; // 例: 笠稲荷神社
  final String commonName; // 例: かさのぎいなりじんじゃ
  final Map<String, dynamic> taxonomy;
  final Map<String, dynamic> description;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.name,
    required this.commonName,
    required this.taxonomy,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy年M月d日').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Column(
        children: [
          ImageHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // タイトルエリア
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 写真
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(imagePath)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(today),
                  const SizedBox(height: 16),
                  // しゃしんをほぞんするボタン
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
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
                    label: const Text("しゃしんをほぞんする"),
                  ),
                  const SizedBox(height: 24),
                  // きほんデータ
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6E5),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description['value'] ?? "説明がありません",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // フッターの余白
                ],
              ),
            ),
          ),
          // フッター
          Container(
            height: 70,
            color: const Color(0xFFE4F8E8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.home, color: Colors.green),
                    Text("ホーム", style: TextStyle(color: Colors.green)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.green),
                    Text("しゃしん", style: TextStyle(color: Colors.green)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.menu_book, color: Colors.green),
                    Text("ずかん", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
