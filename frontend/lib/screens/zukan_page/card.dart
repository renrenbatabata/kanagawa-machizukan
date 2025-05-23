import 'package:flutter/material.dart';
import 'package:frontend/widgets/colors.dart';

class ZukanCard extends StatefulWidget {
  const ZukanCard({super.key});

  @override
  State<ZukanCard> createState() => _ZukanCardState();
}

class _ZukanCardState extends State<ZukanCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.orangeSub,
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
