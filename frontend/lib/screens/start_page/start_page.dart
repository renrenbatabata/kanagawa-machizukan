import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/auth_page/auth.dart';
import 'package:frontend/screens/home_page/home_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    // ★★★ 変更点: ここでログイン状態の自動チェックと遷移を行わない ★★★
    // アニメーションを必ず開始させる
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // アニメーションの長さ
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // アニメーションを開始。完了後に特別な処理は今はなし。
    _logoController.forward();
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
                  animation: _logoFadeAnimation, // フェードアニメーションをボタンのスケールにも利用
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
                      // ★★★ ここが修正点: 「はじめる」ボタンの遷移ロジック ★★★
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // ログイン済みの場合、HomePageへ遷移
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        // 未ログインの場合、AuthScreenへ遷移
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      }
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
