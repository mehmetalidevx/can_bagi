import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Demo için basit login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      // Demo credentials
      if (_usernameController.text == 'admin' && 
          _passwordController.text == 'admin123') {
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hatalı kullanıcı adı veya şifre!'),
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
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo ve başlık
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Can Bağı Admin Panel',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Kullanıcı adı
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kullanıcı adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Şifre
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Giriş butonu
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Giriş Yap'),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Text(
                      'Demo: admin / admin123',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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