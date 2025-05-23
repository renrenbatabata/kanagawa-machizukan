import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart';

class ZukanCard extends StatelessWidget {
  const ZukanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.orangeSub, // 背景色
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.all(10), // 余白

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像
          Image.asset(
            'images/kariImage.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16.0), // 画像とテキストの間隔
          // テキスト情報
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "杉山神社",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                "すぎやまじんじゃ",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4.0),
              Text(
                "2025年5月5日",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
