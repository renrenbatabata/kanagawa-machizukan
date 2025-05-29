// lib/widgets/header.dart を StartPage が含まれるファイル名に読み替えてください
import 'package:flutter/material.dart';
import 'package:frontend/screens/home_page/home_page.dart';

// アニメーションを制御するために StatefulWidget に変更
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  // アニメーション
  late AnimationController _logoController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // === ロゴアニメーションの設定 ===
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // アニメーションの長さ
    );

    // フェードインアニメーション (0.0 から 1.0 へ)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeIn,
        ), // アニメーションの0%から70%でフェードイン
      ),
    );

    // スケールアニメーション (少し拡大)
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(
          0.3,
          1.0,
          curve: Curves.easeOutBack,
        ), // アニメーションの30%から100%で拡大（バウンス効果）
      ),
    );

    _logoController.forward(); // ロゴアニメーションを開始
  }

  @override
  void dispose() {
    _logoController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Positioned.fill(
            child: Image.asset('images/start.png', fit: BoxFit.cover),
          ),

          // コンテンツ
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アプリロゴ（アニメーションで包む）
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Image.asset('images/logo.png', width: 470),
                  ),
                ),
                const SizedBox(height: 90),
                // スタートボタン（アニメーションで包む）
                AnimatedBuilder(
                  animation: _logoFadeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoFadeAnimation.value,
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 136, 89, 2),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 25,
                      ),
                      elevation: 15,
                      shadowColor: const Color.fromARGB(
                        255,
                        62,
                        34,
                        0,
                      ).withAlpha((0.1 * 255).toInt()),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      "はじめる",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
