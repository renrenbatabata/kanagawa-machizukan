// lib/screens/auth_screen/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/widgets/colors.dart'; // 色の定義

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // ユーザーがサインインをキャンセル
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      debugPrint('Googleサインイン成功: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (e) {
      debugPrint('Googleサインインエラー: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ログインに失敗しました: $e')));
      return null;
    }
  }

  // 匿名認証の処理を関数として切り出す (任意)
  Future<void> _signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      debugPrint('匿名サインイン成功: ${userCredential.user?.uid}');
      // 成功したらホーム画面へ
      Navigator.of(context).pushReplacementNamed('/home_page');
    } catch (e) {
      debugPrint('匿名サインインエラー: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ゲストログインに失敗しました: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', height: 150),
            const SizedBox(height: 40),
            Text(
              'ようこそ！',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 50),
            // Googleサインインボタン
            ElevatedButton.icon(
              onPressed: () async {
                UserCredential? userCredential = await _signInWithGoogle();
                if (userCredential != null) {
                  debugPrint('ログイン後のホーム画面へ遷移');
                  // ログイン成功したらNamed Routeでホーム画面へ置き換え遷移
                  Navigator.of(context).pushReplacementNamed('/home_page');
                }
              },
              icon: Image.asset(
                'images/google_logo.png',
                height: 24,
              ), // Googleロゴ画像
              label: const Text(
                'Googleでログイン',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 20),
            // ゲストとして続ける（匿名認証）オプション
            TextButton(
              onPressed: _signInAnonymously, // 関数呼び出しに変更
              child: Text(
                'ログインせずに始める（ゲスト利用）',
                style: TextStyle(fontSize: 16, color: AppColors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
