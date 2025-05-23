import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 丸い×ボタン
          IconButton(
            icon: const Icon(Icons.close, color: Colors.brown),
            iconSize: 40,
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Colors.brown.withAlpha((255 * 0.1).round()),
              ),
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'もどる',
            style: TextStyle(fontSize: 14, color: Colors.brown),
          ),
        ],
      ),
    );
  }
}
