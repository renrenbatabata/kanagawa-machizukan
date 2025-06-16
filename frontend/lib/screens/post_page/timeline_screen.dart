import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // JSONエンコード・デコード用
import 'package:http/http.dart' as http; // httpパッケージを追加

import 'package:frontend/screens/post_page/post_card.dart'; // PostCardウィジェットをインポート
import 'package:frontend/screens/post_page/post.dart'; // Postモデルをインポート
import 'package:frontend/screens/post_page/post_upload_screen.dart'; // 投稿画面をインポート

// dotenvとAuthServiceのインポートを追加
import 'package:flutter_dotenv/flutter_dotenv.dart';
// AuthServiceはあなたのプロジェクトのパスに合わせて調整してください
import 'package:frontend/screens/auth_page/auth_service.dart'; // AuthServiceをインポート

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final List<Post> _posts = [];
  late final WebSocketChannel _channel; // WebSocket チャンネル
  // _serverBaseUrlはdotenvから取得するように変更するため、ここでは初期化しない
  String? _errorMessage; // エラーメッセージ表示用
  bool _isLoadingInitialPosts = false; // 初期投稿ロード中フラグ

  // WebSocket URLもdotenvから取得することを想定
  String? _baseApiUrl; // BASE_API_URLを格納する変数

  @override
  void initState() {
    super.initState();
    _initializeTimeline(); // 初期化処理をまとめる
  }

  Future<void> _initializeTimeline() async {
    setState(() {
      _isLoadingInitialPosts = true;
      _errorMessage = null; // エラーメッセージをリセット
    });

    // .envからBASE_API_URLを取得
    _baseApiUrl = dotenv.env['BASE_API_URL'];

    if (_baseApiUrl == null) {
      _errorMessage = 'Error: BASE_API_URLが設定されていません。';
      _isLoadingInitialPosts = false;
      print('❌ BASE_API_URLが設定されていません。');
      // ここでエラー表示を更新
      if (mounted) {
        setState(() {}); // UIを更新してエラーメッセージを表示
      }
      return;
    }

    // 初期投稿のロード
    await _fetchInitialPosts();

    // WebSocket接続の確立
    _connectWebSocket();

    // 初期ロードが完了
    if (mounted) {
      setState(() {
        _isLoadingInitialPosts = false;
      });
    }
  }

  Future<void> _fetchInitialPosts() async {
    // ユーザーIDは初期投稿の取得には必須ではない場合も多いですが、
    // 必要であればここでAuthService().currentUserId を取得し、クエリパラメータやヘッダーに含める
    final userId = AuthService().currentUserId; // ユーザーIDはAuthServiceから取得
    print('✅ User ID for initial posts: $userId'); // デバッグ用

    try {
      final response = await http.get(
        Uri.parse('$_baseApiUrl/api/posts'),
      ); // Spring BootのAPIエンドポイント

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _posts.addAll(data.map((json) => Post.fromJson(json)).toList());
            _posts.sort(
              (a, b) => b.timestamp.compareTo(a.timestamp),
            ); // 新しい順にソート
          });
        }
      } else {
        final errorMsg = '初期投稿のロードに失敗しました: ${response.statusCode}';
        print(errorMsg);
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
          });
        }
      }
    } catch (e) {
      final errorMsg = '初期投稿のロード中にエラーが発生しました: $e';
      print(errorMsg);
      if (mounted) {
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    }
  }

  void _connectWebSocket() {
    if (_baseApiUrl == null) {
      print('❌ WebSocket接続: BASE_API_URLが未設定のため接続できません。');
      return;
    }
    // WebSocketのURLは、HTTPのBASE_API_URLをws://に変換して利用
    final wsUrl = _baseApiUrl!.replaceFirst('http', 'ws') + '/ws/timeline';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen(
      (message) {
        // メッセージを受信したら、投稿データとしてパースし、リストに追加
        final Map<String, dynamic> data = jsonDecode(message);
        final newPost = Post.fromJson(data);
        if (mounted) {
          setState(() {
            _posts.insert(0, newPost); // 最新の投稿をリストの先頭に追加
          });
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
        if (mounted) {
          setState(() {
            _errorMessage = 'リアルタイム更新エラー: $error';
          });
        }
        // エラー処理 (例: 再接続試行、エラーメッセージ表示)
      },
      onDone: () {
        print('WebSocket Closed');
        // 接続切断時の処理 (例: 再接続試行)
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close(); // 画面を離れるときにWebSocket接続を閉じる
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // サーバーURLがまだ設定されていない場合、またはロード中の表示
    if (_baseApiUrl == null && _errorMessage == null) {
      return const Center(child: CircularProgressIndicator()); // 初期ロード中の表示
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            if (_baseApiUrl == null) // BASE_API_URL未設定の場合にリトライボタンを出す
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _initializeTimeline, // 初期化を再試行
                  child: const Text('再試行'),
                ),
              ),
          ],
        ),
      );
    }

    if (_isLoadingInitialPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('みんなのまち図鑑タイムライン')),
      body:
          _posts.isEmpty
              ? const Center(child: Text('まだ投稿がありません。'))
              : ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: _posts[index]);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 投稿画面へ遷移
          if (_baseApiUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PostUploadScreen(serverBaseUrl: _baseApiUrl!),
              ),
            );
          } else {
            // エラーメッセージを表示
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('APIのURLが設定されていません。')));
          }
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
