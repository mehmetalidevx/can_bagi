import 'package:flutter/material.dart';
import 'package:can_bagi/screens/login_screen.dart';
import 'package:can_bagi/screens/home_screen.dart';
import 'package:can_bagi/services/auth_service.dart';
import 'package:can_bagi/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      // Kullanıcının giriş durumunu kontrol et
      final user = await AuthService.getCurrentUser();
      
      if (user != null) {
        print('✅ Kullanıcı zaten giriş yapmış: ${user.email}');
        // Kullanıcı giriş yapmış, direkt home screen'e git
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print('❌ Kullanıcı giriş yapmamış, login screen\'e yönlendiriliyor');
        // Kullanıcı giriş yapmamış, login screen'e git
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('❌ Auth kontrol hatası: $e');
      // Hata durumunda login screen'e git
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo yerine geçici olarak bir ikon kullanıyoruz
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Can Bağı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hayat Kurtaran Bağlantı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}