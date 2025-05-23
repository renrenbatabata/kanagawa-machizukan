import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/widgets/colors.dart';

class KanagawaLoveArea extends StatelessWidget {
  const KanagawaLoveArea({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      children: [
        _buildLoveTile(
          context,
          color: AppColors.orange,
          subcolor: AppColors.orangeSub,
          icon: Icons.search,
          label: 'すべて',
          points: '300',
        ),
        _buildLoveTile(
          context,
          color: AppColors.pink,
          subcolor: AppColors.pinkSub,
          icon: Icons.local_florist,
          label: 'おはな',
          points: '100',
        ),
        _buildLoveTile(
          context,
          color: AppColors.blue,
          subcolor: AppColors.blueSub,
          icon: CupertinoIcons.tortoise,
          label: 'かめ太郎',
          points: '100',
        ),
        _buildLoveTile(
          context,
          color: AppColors.red,
          subcolor: AppColors.redSub,
          icon: Icons.temple_hindu,
          label: 'じんじゃ',
          points: '100',
        ),
      ],
    );
  }

  Widget _buildLoveTile(
    BuildContext context, {
    required Color color,
    required Color subcolor,
    required IconData icon,
    required String label,
    required String points,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 28, color: Colors.white),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: subcolor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: points,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const TextSpan(
                      text: ' こ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
