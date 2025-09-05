// lib/widgets/header.dart
import 'package:flutter/material.dart';

class ImageHeader extends StatelessWidget {
  const ImageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'images/header.png',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}
