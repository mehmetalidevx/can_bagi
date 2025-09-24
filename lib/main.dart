import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/screens/splash_screen.dart';
import 'package:can_bagi/screens/admin_login_screen.dart';
import 'package:can_bagi/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env dosyası başarıyla yüklendi");
  } catch (e) {
    print("❌ .env dosyası yüklenemedi: $e");
  }
  
  try {
    // Web ve mobil için farklı Firebase initialization
    if (kIsWeb) {
      // Web için Firebase config
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC7TslTTFahVT-dyeT_iMvRJ2-QxTGaFPI",
          authDomain: "can-bagi.firebaseapp.com",
          projectId: "can-bagi",
          storageBucket: "can-bagi.firebasestorage.app",
          messagingSenderId: "277485623590",
          appId: "1:277485623590:web:ab4eec623954f1f2dd49e7",
          measurementId: "G-N897CRLZP2",
        ),
      );
    } else {
      // Mobil için (google-services.json kullanır)
      await Firebase.initializeApp();
    }
    print("✅ Firebase başarıyla başlatıldı");
  } catch (e) {
    print("❌ Firebase başlatılamadı: $e");
    print("Firebase özellikleri çalışmayacak");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Can Bağı',
      theme: AppTheme.lightTheme,
      locale: const Locale('tr', 'TR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => _getInitialScreen(),
        '/admin': (context) => const AdminLoginScreen(),
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getInitialScreen() {
    // Web'de URL kontrol et
    if (kIsWeb) {
      final uri = Uri.base;
      if (uri.path.contains('/admin')) {
        return const AdminLoginScreen();
      }
    }
    
    // Mobil veya normal web için splash screen
    return const SplashScreen();
  }
}
