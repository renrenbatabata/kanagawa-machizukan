import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/screens/auth_page/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  // 環境変数の読み込み
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Firebase初期化
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize();
  AuthService().initialize();
  runApp(const MyApp());
}
