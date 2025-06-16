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

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ★ 画面の幅を取得
    final screenWidth = MediaQuery.of(context).size.width;
    // ★ ボタンの目標幅を設定（例: 画面幅の70%）
    // 必要に応じて、minWidth, maxWidth を設定して最小・最大サイズを制御することも可能です。
    final double buttonWidth = screenWidth * 0.7; // 画面幅の70%

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
                  // ★ ここをSizedBoxでラップして幅を制御
                  child: SizedBox(
                    // ★追加
                    width: buttonWidth, // ★変更: 計算した幅を適用
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
                        // padding: const EdgeInsets.symmetric( // ★ paddingは削除または調整
                        //   horizontal: 70, // 幅はSizedBoxで指定するため、水平パディングは不要に
                        //   vertical: 25,
                        // ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 25,
                        ), // 垂直パディングのみ維持
                        elevation: 15,
                        shadowColor: const Color.fromARGB(
                          255,
                          62,
                          34,
                          0,
                        ).withAlpha((0.1 * 255).toInt()),
                      ),
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        } else {
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
                  ), // ★SizedBoxの閉じタグを追加
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
