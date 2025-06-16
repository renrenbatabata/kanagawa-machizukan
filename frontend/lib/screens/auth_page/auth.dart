import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/widgets/colors.dart'; // 色の定義
import 'package:frontend/screens/home_page/home_page.dart';

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
      // Googleサインインフロー開始前に既存セッションをクリア（ユーザーがアカウントを選択し直せるように）
      await _googleSignIn.signOut();

      // Googleサインインフローを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした場合
        return null;
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

  @override
  Widget build(BuildContext context) {
    // ★ 画面の幅を取得
    final screenWidth = MediaQuery.of(context).size.width;
    // ★ ボタンの目標幅を設定（例: 画面幅の80%）
    final double buttonWidth = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E5), // やさしいベージュ
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/start.png', fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0), // 画面端からの余白
              padding: const EdgeInsets.all(35.0), // コンテンツ内側の余白
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // 白の半透明
                borderRadius: BorderRadius.circular(20.0), // 角丸
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // コンテンツのサイズに合わせる
                crossAxisAlignment: CrossAxisAlignment.center, // 水平方向中央揃え
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'images/logo.png',
                    height: 170, // ロゴのサイズを調整して、メッセージとのバランスを取る
                  ),
                  const SizedBox(height: 30), // ロゴとメッセージの間隔
                  // メッセージ
                  Text(
                    'アカウントを作成しよう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, // フォントサイズを調整
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 68, 68, 68), // 黒に近いグレー
                    ),
                  ),
                  const SizedBox(height: 50), // メッセージとボタンの間隔を広げる
                  // Googleサインインボタン
                  // ★ ここをSizedBoxでラップして幅を制御
                  SizedBox(
                    // ★追加
                    width: buttonWidth, // ★変更: 計算した幅を適用
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        UserCredential? userCredential =
                            await _signInWithGoogle();
                        if (userCredential != null) {
                          debugPrint('ログイン後のホーム画面へ遷移');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }
                      },
                      icon: Image.asset(
                        'images/google_logo.png',
                        height: 32, // Googleロゴをさらに大きく
                      ),
                      label: const Text(
                        'Googleでログイン', // より簡潔な「ログイン」を強調
                        style: TextStyle(
                          fontSize: 22, // フォントサイズをさらに大きく
                          color: Colors.black87,
                          fontWeight: FontWeight.bold, // 太字を強調
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white, // 白背景
                        // padding: const EdgeInsets.symmetric( // ★ paddingは削除または調整
                        //   horizontal: 50, // 幅はSizedBoxで指定するため、水平パディングは不要に
                        //   vertical: 20,
                        // ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                        ), // 垂直パディングのみ維持
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // 角丸をさらに大きく
                          side: BorderSide(
                            color: Colors.grey.shade400, // 枠線を少し濃く
                            width: 2, // 枠線を太く
                          ),
                        ),
                        shadowColor: Colors.black.withOpacity(0.4), // 影をさらに濃く
                        elevation: 10, // 影の深さを強調
                      ),
                    ),
                  ), // ★SizedBoxの閉じタグを追加
                  const SizedBox(height: 40), // ボタン下の余白 (必要に応じて調整)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
