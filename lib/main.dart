import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Şimdilik yorum satırına alıyoruz
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Şimdilik yorum satırına alıyoruz
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Can Bağı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
