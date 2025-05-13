import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SelectTargetScreen extends StatelessWidget {
  const SelectTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF4EF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: Colors.brown),
                  label: const Text(
                    'もどる',
                    style: TextStyle(fontSize: 16, color: Colors.brown),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'しゃしんをとりたいのを\nえらぼう！',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _TargetButton(
                icon: Icons.local_florist,
                label: 'おはな',
                color: Colors.pinkAccent,
                onTap: () {
                  // 次の画面へ（例: Navigator.push）
                },
              ),
              const SizedBox(height: 16),
              _TargetButton(
                icon: Icons.temple_buddhist,
                label: 'じんじゃ',
                color: Colors.redAccent,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _TargetButton(
                icon: CupertinoIcons.tortoise,
                label: 'かめ太郎',
                color: Colors.indigoAccent,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 共通ボタンウィジェット
class _TargetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TargetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
