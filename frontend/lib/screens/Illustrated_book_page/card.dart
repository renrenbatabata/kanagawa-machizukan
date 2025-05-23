import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart';

class IllustratedCard extends StatefulWidget {
  const IllustratedCard({super.key});

  @override
  State<IllustratedCard> createState() => _IllustratedCardState();
}

class _IllustratedCardState extends State<IllustratedCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.redSub,
        child: Center(
          child: Row(
            children: [
              Image.asset('images/kariImage.png'),
              Column(
                children: [Text("杉山神社"), Text("すぎやまじんじゃ"), Text("2025年5月5日")],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
