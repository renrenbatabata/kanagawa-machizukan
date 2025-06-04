// lib/auth/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // シングルトンインスタンス
  static final AuthService _instance = AuthService._internal();

  // ファクトリーコンストラクタ
  factory AuthService() {
    return _instance;
  }

  // プライベートコンストラクタ
  AuthService._internal();

  // 現在のユーザーIDを保持する変数
  String? _currentUserId;

  // ユーザーIDを取得するゲッター
  String? get currentUserId => _currentUserId;

  // ログインしているユーザーのIDを設定するメソッド
  void setUserId(String? userId) {
    _currentUserId = userId;
    print('AuthService: ユーザーIDが設定されました: $_currentUserId');
  }

  // Firebase認証の状態を監視し、userIdを自動更新する
  void initialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setUserId(user.uid);
      } else {
        setUserId(null); // ログアウトしたらIDをクリア
      }
    });
  }
}
