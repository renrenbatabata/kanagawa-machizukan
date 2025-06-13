import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class XOfficialNoticeScreen extends StatefulWidget {
  const XOfficialNoticeScreen({super.key});

  @override
  State<XOfficialNoticeScreen> createState() => _XOfficialNoticeScreenState();
}

class _XOfficialNoticeScreenState extends State<XOfficialNoticeScreen> {
  late final WebViewController _controller;

  // X Publishで生成した埋め込みコード（<iframe>を含むHTML全体）をここに記述します。
  // 例:
  // "<a class=\"twitter-timeline\" href=\"https://x.com/yokohama_KNGW?ref_src=twsrc%5Etfw\">Tweets by yokohama_KNGW</a> <script async src=\"https://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
  final String _xEmbedHtml = """
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">【<a href="https://twitter.com/hashtag/%E3%83%97%E3%83%BC%E3%83%AB?src=hash&amp;ref_src=twsrc%5Etfw">#プール</a> に行こう！】<br>６月1４日(土)から <a href="https://twitter.com/hashtag/%E5%AD%90%E5%AE%89%E5%B0%8F%E5%AD%A6%E6%A0%A1%E3%83%97%E3%83%BC%E3%83%AB?src=hash&amp;ref_src=twsrc%5Etfw">#子安小学校プール</a> の一般開放がスタート！<br>入口は「打越公園前のゲート」だよ👀<br>ルールを守って楽しく泳ごう🏊<a href="https://twitter.com/hashtag/%E7%A5%9E%E5%A5%88%E5%B7%9D%E5%8C%BA?src=hash&amp;ref_src=twsrc%5Etfw">#神奈川区</a> <a href="https://twitter.com/hashtag/%E3%81%8B%E3%82%81%E5%A4%AA%E9%83%8E?src=hash&amp;ref_src=twsrc%5Etfw">#かめ太郎</a><br><br>子安小学校プール👉<a href="https://t.co/ERCRZRvTIE">https://t.co/ERCRZRvTIE</a> <a href="https://t.co/1yJb4Ds6AS">pic.twitter.com/1yJb4Ds6AS</a></p>&mdash; 横浜市神奈川区役所 (@yokohama_KNGW) <a href="https://twitter.com/yokohama_KNGW/status/1933313370112876924?ref_src=twsrc%5Etfw">June 13, 2025</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>  """; // data-heightは表示したい高さに合わせて調整してください。

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScriptを有効にする
          ..setBackgroundColor(const Color(0x00000000)) // 背景を透明に（任意）
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // ロードの進捗を表示するロジックをここに追加（任意）
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView Error: ${error.description}');
              },
              onNavigationRequest: (NavigationRequest request) {
                // Xの投稿内のリンクなどをクリックした際の挙動を制御できます。
                // 例えば、アプリ内ブラウザで開くか、外部ブラウザで開くかなど。
                // return NavigationDecision.prevent; // アプリ内での遷移をブロック
                return NavigationDecision.navigate; // そのまま遷移を許可
              },
            ),
          )
          ..loadHtmlString(_xEmbedHtml); // 生成したHTML文字列を読み込む
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('区役所からのお知らせ')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
