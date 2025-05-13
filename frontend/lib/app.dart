import 'package:flutter/material.dart';
import 'screens/select_target/select_target_screen.dart';
import 'screens/take_photo/take_photo_screen.dart';
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
      initialRoute: '/select_target', // 最初の画面
      routes: {
        '/select_target': (context) => const SelectTargetScreen(),
        '/take_photo': (context) => const TakePhotoScreen(),
        // '/preview': (context) => const PreviewScreen(),
        // '/home': (context) => const HomeScreen(),
        '/camera': (context) => const SelectTargetScreen(),
        // '/zukan': (context) => const ZukanScreen(),
      },
    );
  }
}
