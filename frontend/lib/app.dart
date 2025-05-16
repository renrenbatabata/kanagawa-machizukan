import 'package:flutter/material.dart';
import 'screens/select_target/select_target_screen.dart';
import 'screens/start_page/start_page.dart';
import 'screens/home_page/home_page.dart';

// import 'screens/take_photo/take_photo_screen.dart';
// import 'screens/preview/preview_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かながわく まち図鑑',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'NotoSansJP',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),

      initialRoute: '/start_page', // 最初の画面
      routes: {
        '/start_page': (context) => const StartPage(),
        '/home_page': (context) => const HomePage(),
        '/select_target': (context) => const SelectTargetScreen(),
        '/camera': (context) => const SelectTargetScreen(),
      },
    );
  }
}
