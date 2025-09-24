import 'package:flutter/material.dart';
import 'package:can_bagi/screens/register_screen.dart';
import 'package:can_bagi/screens/home_screen.dart';
import 'package:can_bagi/screens/forgot_password_screen.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/services/auth_service.dart'; // Bu satırı ekleyin

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // Şifre görünürlüğü için eklendi

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('🔄 Firebase giriş işlemi başlatılıyor...');
        print('📧 Email: ${_emailController.text}');
        
        final result = await AuthService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result != null) {
          print('✅ Firebase giriş başarılı!');
          print('🆔 User ID: ${result.user?.uid}');
          print('📧 User Email: ${result.user?.email}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giriş başarılı! Hoş geldiniz!'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          print('❌ Firebase giriş başarısız - result null!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giriş başarısız. Email veya şifre hatalı.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('💥 Firebase giriş hatası: $e');
        String errorMessage = 'Bilinmeyen hata';
        
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Bu email adresi ile kayıtlı kullanıcı bulunamadı';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Hatalı şifre';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Geçersiz email adresi';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'Bu hesap devre dışı bırakılmış';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo ve başlık için container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppTheme.primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Can Bağı',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Giriş Yap',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Form alanları için container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-posta',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen e-posta adresinizi girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen şifrenizi girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text('Şifremi Unuttum'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Giriş Yap'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Hesabınız yok mu?'),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Kayıt Ol'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}