import 'package:flutter/material.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/screens/zukan_page/zukan_card.dart';
import 'package:frontend/widgets/colors.dart';

class Zukan extends StatefulWidget {
  const Zukan({super.key});

  @override
  State<Zukan> createState() => _ZukanState();
}

class _ZukanState extends State<Zukan> {
  String selectedCategory = "すべて";

  // カテゴリと対応するカラー
  final Map<String, Map<String, Color>> categoryColors = {
    "すべて": {"main": AppColors.orange, "sub": AppColors.orangeSub},
    "おはな": {"main": AppColors.pink, "sub": AppColors.pinkSub},
    "じんじゃ": {"main": AppColors.red, "sub": AppColors.redSub},
    "かめ太郎": {"main": AppColors.blue, "sub": AppColors.blueSub},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          const SizedBox(height: 30.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  categoryColors.keys.map((category) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              selectedCategory == category
                                  ? categoryColors[category]!["main"]
                                  : categoryColors[category]!["sub"],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 5.8,
              right: 2.0,
              top: 0,
              bottom: -2.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: categoryColors[selectedCategory]!["main"],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: const ZukanCard(),
            ),
          ),
          const Control(),
        ],
      ),
    );
  }
}
