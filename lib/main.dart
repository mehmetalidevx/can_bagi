import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase'i başlat
    await Firebase.initializeApp();
    print("✅ Firebase başarıyla başlatıldı");
  } catch (e) {
    print("❌ Firebase başlatılamadı: $e");
    print("Firebase özellikleri çalışmayacak");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Can Bağı',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
