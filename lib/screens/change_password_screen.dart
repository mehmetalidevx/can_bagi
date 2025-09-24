import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Şifre başarıyla değiştirildi'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              
              // Mevcut Şifre
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mevcut şifrenizi girin';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Yeni Şifre
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen yeni şifrenizi girin';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Şifre Tekrar
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  prefixIcon: const Icon(Icons.lock_reset, color: AppTheme.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen şifrenizi tekrar girin';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 48),
              
              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Değiştiriliyor...' : 'Şifreyi Değiştir',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}