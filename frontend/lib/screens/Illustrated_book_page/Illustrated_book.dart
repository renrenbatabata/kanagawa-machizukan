import 'package:flutter/material.dart';
import 'package:frontend/widgets/control.dart';
import 'package:frontend/widgets/header.dart';
import 'package:frontend/screens/Illustrated_book_page/card.dart';

class IllustratedBook extends StatefulWidget {
  const IllustratedBook({super.key});

  @override
  State<IllustratedBook> createState() => _IllustratedBookState();
}

class _IllustratedBookState extends State<IllustratedBook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          const IllustratedCard(),
          const Control(),
        ],
      ),
    );
  }
}
