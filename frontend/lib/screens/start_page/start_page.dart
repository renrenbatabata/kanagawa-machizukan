// lib/screens/start_page/start_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authenticationをインポート
import 'package:frontend/screens/auth_screen/auth_screen.dart'; // AuthScreenをインポート
import 'package:frontend/screens/home_page/home_page.dart'; // HomePageをインポート

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

    // アニメーション設定前にログイン状態をチェック
    // ウィジェットツリーが完全に構築される前に遷移を試みるため、
    // addPostFrameCallback を使用して、描画フレームの後に実行させる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatusAndNavigate();
    });

    // === ロゴアニメーションの設定 ===
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

    // ログインチェック後、未ログインの場合のみアニメーションを開始
    // _checkLoginStatusAndNavigate()の中で_logoController.forward()を呼び出す
  }

  // ログイン状態をチェックし、適切な画面へ遷移する関数
  void _checkLoginStatusAndNavigate() {
    final user = FirebaseAuth.instance.currentUser; // 現在のユーザーを取得

    if (user != null) {
      // ユーザーが既にログインしている場合
      // アニメーションを待たずに直接HomePageへ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // ユーザーがログインしていない場合
      // アニメーションを開始し、StartPageを表示
      _logoController.forward();
    }
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
                      // 「はじめる」ボタンが押されたらAuthScreenへ遷移
                      Navigator.pushReplacement(
                        // ★pushReplacementに変更
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
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
