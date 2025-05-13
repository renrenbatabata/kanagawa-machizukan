import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/header.dart'; // パスはプロジェクト構成に合わせて

class PicturePreviewScreen extends StatelessWidget {
  final String imagePath;

  const PicturePreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ImageHeader(),
          Expanded(child: Center(child: Image.file(File(imagePath)))),
        ],
      ),
    );
  }
}
