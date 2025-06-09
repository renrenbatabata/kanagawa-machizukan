import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/screens/result_page/result_actions.dart';
import 'package:intl/intl.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/widgets/control.dart';

class FlowerResultPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String family;
  final String genius;
  final String? meaning;
  final String description;
  final String? location;
  final String? category;
  final String? uuid;

  const FlowerResultPage({
    super.key,
    required this.imagePath,
    required this.name, //名前
    required this.family, //科
    required this.genius, //目
    this.meaning, //花言葉
    required this.description, //説明
    this.location,
    required this.category,
    this.uuid,
  });

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('yyyy年M月d日').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5),
      body: Column(
        children: [
          ImageHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder<Uint8List>(
                future: File(imagePath).readAsBytes(), // 非同期で画像を読み込み
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("画像の読み込みに失敗しました"));
                  } else {
                    return Column(
                      children: [
                        const SizedBox(height: 30),
                        // タイトル
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            // constを追加
                            color: Color(0xFFFFF6E5),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 写真表示
                        Center(
                          child: Container(
                            width: 350,
                            height: 350,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),
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
                        Text(today, style: const TextStyle(fontSize: 16)),

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
                                  color: const Color.fromARGB(
                                    161,
                                    251,
                                    215,
                                    148,
                                  ),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "分類 : $family $genius",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 8),
                                    // meaningがnullでなければ表示
                                    if (meaning != null && meaning!.isNotEmpty)
                                      Text(
                                        "花言葉 :$meaning",
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                      description,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    if (location != null &&
                                        location!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          "撮影場所: $location",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ResultActions(
                          uuid: uuid ?? '', // uuidがnullの場合は空文字を渡す
                          category: category ?? '', // categoryがnullの場合は空文字を渡す
                        ),
                        const SizedBox(height: 80),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Control(),
        ],
      ),
    );
  }
}
