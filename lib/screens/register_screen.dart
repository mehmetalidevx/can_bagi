import 'package:flutter/material.dart';
import 'package:can_bagi/screens/home_screen.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _selectedBloodType;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> _bloodTypes = [
    {'type': 'A Rh+', 'color': Colors.red.shade400, 'icon': Icons.water_drop},
    {'type': 'A Rh-', 'color': Colors.red.shade300, 'icon': Icons.water_drop_outlined},
    {'type': 'B Rh+', 'color': Colors.blue.shade400, 'icon': Icons.water_drop},
    {'type': 'B Rh-', 'color': Colors.blue.shade300, 'icon': Icons.water_drop_outlined},
    {'type': 'AB Rh+', 'color': Colors.purple.shade400, 'icon': Icons.water_drop},
    {'type': 'AB Rh-', 'color': Colors.purple.shade300, 'icon': Icons.water_drop_outlined},
    {'type': '0 Rh+', 'color': Colors.orange.shade400, 'icon': Icons.water_drop},
    {'type': '0 Rh-', 'color': Colors.orange.shade300, 'icon': Icons.water_drop_outlined},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBloodType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen kan grubunuzu seçin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Şifre uzunluğu kontrolü
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre en az 6 karakter olmalıdır'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        print('🔄 Firebase kayıt işlemi başlatılıyor...');
        print('📧 Email: ${_emailController.text}');
        print('👤 Ad Soyad: ${_nameController.text}');
        print('🩸 Kan Grubu: $_selectedBloodType');
        print('📱 Telefon: ${_phoneController.text}');
        print('🔐 Şifre uzunluğu: ${_passwordController.text.length}');

        final result = await AuthService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          bloodType: _selectedBloodType!,
          phone: _phoneController.text.trim(),
        );

        if (result != null) {
          print('✅ Firebase kayıt başarılı!');
          print('🆔 User ID: ${result.user?.uid}');
          print('📧 User Email: ${result.user?.email}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt başarılı! Hoş geldiniz!'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          print('❌ Firebase kayıt başarısız - result null!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt işlemi başarısız. Email zaten kullanımda olabilir.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('💥 Firebase kayıt hatası: $e');
        String errorMessage = 'Bilinmeyen hata';
        
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'Bu email adresi zaten kullanımda';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Şifre çok zayıf';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Geçersiz email adresi';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'İnternet bağlantısını kontrol edin';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Kayıt Ol',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Dengelemek için
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: AppTheme.primaryColor,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Yeni Hesap Oluştur',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Ad Soyad',
                                    prefixIcon: Icon(Icons.person_outline),
                                    hintText: 'Adınız ve soyadınız',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen adınızı ve soyadınızı girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'E-posta',
                                    prefixIcon: Icon(Icons.email_outlined),
                                    hintText: 'ornek@email.com',
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
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    hintText: 'En az 6 karakter',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                                    if (value.length < 6) {
                                      return 'Şifre en az 6 karakter olmalıdır';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Kan Grubunuzu Seçin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _bloodTypes.length,
                          itemBuilder: (context, index) {
                            final bloodType = _bloodTypes[index];
                            final isSelected = _selectedBloodType == bloodType['type'];
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBloodType = bloodType['type'];
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected ? bloodType['color'] : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? bloodType['color'] : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: bloodType['color'].withOpacity(0.4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      bloodType['icon'],
                                      color: isSelected ? Colors.white : bloodType['color'],
                                      size: 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bloodType['type'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (_formKey.currentState?.validate() == false && _selectedBloodType == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              'Lütfen kan grubunuzu seçin',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Kayıt Ol', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}