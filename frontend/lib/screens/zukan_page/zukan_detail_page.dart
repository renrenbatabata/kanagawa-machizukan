import 'dart:io'; // Fileクラスを使用するために必要
import 'package:flutter/material.dart';
import 'package:frontend/widgets/back_button.dart';
import 'package:frontend/widgets/header.dart'; // ImageHeaderをインポート
import 'package:frontend/widgets/control.dart'; // Controlをインポート
import 'package:frontend/widgets/colors.dart'; // AppColorsをインポート

class ZukanDetailPage extends StatelessWidget {
  final Map<String, dynamic> details;
  final String? capturedImagePath; // 新しく追加：発見時の撮影画像パス (FilePath)

  const ZukanDetailPage({
    Key? key,
    required this.details,
    this.capturedImagePath, // オプショナル引数として追加
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 詳細情報から名前、読み仮名、説明、画像URL、場所を取得
    final String name = details['name'] ?? '名称不明';
    final String hiraganaName =
        details['hiraganaName'] ?? ''; // 仮の読み仮名、バックエンドから取得想定
    final String description = details['description'] ?? '詳しい説明はありません。';
    // isDiscoveredはZukanItemから渡されるが、ZukanDetailPageでは常に発見済みとして扱う
    final String? displayImageUrl = details['imageUrl']; // DBに登録された公式画像
    final String discoveredDate = details['discoveredDate'] ?? ''; // 発見日 (あれば)
    final String location = details['location'] ?? '場所不明'; // 場所 (あれば)

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

                  // 写真（発見時の写真があればそれを優先、なければ図鑑の公式画像）
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
                          (capturedImagePath != null &&
                                  File(capturedImagePath!).existsSync())
                              ? Image.file(
                                File(capturedImagePath!),
                                fit: BoxFit.cover,
                              )
                              : (displayImageUrl != null &&
                                  displayImageUrl.isNotEmpty)
                              ? Image.asset(
                                displayImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
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
                  if (discoveredDate.isNotEmpty)
                    Text(
                      '発見日: $discoveredDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 「きほんデータ」セクション
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ), // 全体のパディングを調整
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 左寄せにする
                      children: [
                        // タイトル部分
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 8,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.orange, // オレンジ
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min, // コンテンツに合わせて幅を最小限に
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.white,
                              ), // アイコンを変更
                              SizedBox(width: 8), // アイコンとテキストの間隔を調整
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
                        // データ表示部分
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12), // 下側を丸くする
                              bottomRight: Radius.circular(12), // 下側を丸くする
                              topRight: Radius.circular(12),
                            ),
                            color: AppColors.orangeSub.withOpacity(
                              0.5,
                            ), // 半透明の薄いオレンジ
                            border: Border.all(
                              color: AppColors.orange,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              if (location.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  '場所: $location',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                              // ここに関連情報、アクセス、イベントなどを追加
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
