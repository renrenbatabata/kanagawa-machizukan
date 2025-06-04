import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/widgets/colors.dart'; // 色の定義
import 'package:frontend/screens/home_page/home_page.dart'; // HomePageをインポート

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
                    'きみだけのずかんをつくろう！',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25, // フォントサイズを調整
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 68, 68, 68), // 黒に近いグレー
                    ),
                  ),
                  const SizedBox(height: 50), // メッセージとボタンの間隔を広げる
                  // Googleサインインボタン
                  ElevatedButton.icon(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50, // 横方向のパディングをさらに広げる
                        vertical: 20, // 縦方向のパディングをさらに広げる
                      ),
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
