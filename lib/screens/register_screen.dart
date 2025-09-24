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
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _weightController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;
  bool _kvkkAccepted = false;

  final List<String> _genders = ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'];

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
    _cityController.dispose();
    _districtController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 yaş
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen cinsiyetinizi seçin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedBirthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen doğum tarihinizi seçin'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_kvkkAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen KVKK ve Gizlilik Politikasını kabul edin'),
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
        print('🏙️ Şehir: ${_cityController.text}');
        print('🏘️ İlçe: ${_districtController.text}');
        print('👥 Cinsiyet: $_selectedGender');
        print('🎂 Doğum Tarihi: ${_selectedBirthDate?.toIso8601String()}');
        print('⚖️ Kilo: ${_weightController.text}');
        print('🔐 Şifre uzunluğu: ${_passwordController.text.length}');

        final result = await AuthService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          bloodType: _selectedBloodType!,
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          gender: _selectedGender!,
          birthDate: _selectedBirthDate!,
          weight: double.tryParse(_weightController.text) ?? 0.0,
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
                        
                        // Kişisel Bilgiler
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kişisel Bilgiler',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Geçerli bir e-posta adresi girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefon',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                    hintText: '0555 123 45 67',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen telefon numaranızı girin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cityController,
                                        decoration: const InputDecoration(
                                          labelText: 'Şehir',
                                          prefixIcon: Icon(Icons.location_city_outlined),
                                          hintText: 'İstanbul',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lütfen şehrinizi girin';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _districtController,
                                        decoration: const InputDecoration(
                                          labelText: 'İlçe',
                                          prefixIcon: Icon(Icons.location_on_outlined),
                                          hintText: 'Kadıköy',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Lütfen ilçenizi girin';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Doğum Tarihi
                                GestureDetector(
                                  onTap: _selectBirthDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _selectedBirthDate == null 
                                                ? 'Doğum Tarihi Seçin' 
                                                : _formatDate(_selectedBirthDate!),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _selectedBirthDate == null ? Colors.grey : Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                                             const SizedBox(height: 16),
                                // Cinsiyet
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  decoration: const InputDecoration(
                                    labelText: 'Cinsiyet',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  items: _genders.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Lütfen cinsiyetinizi seçin';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Kilo
                                TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Kilo (kg)',
                                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                                    hintText: '70',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen kilonuzu girin';
                                    }
                                    final weight = double.tryParse(value);
                                    if (weight == null || weight <= 0 || weight > 300) {
                                      return 'Geçerli kilo girin (1-300 kg)';
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
                        
                        // Kan Grubu Seçimi
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
                        
                        const SizedBox(height: 24),
                        
                        // KVKK Onayı
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _kvkkAccepted,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _kvkkAccepted = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _kvkkAccepted = !_kvkkAccepted;
                                      });
                                    },
                                    child: const Text(
                                      'KVKK ve Gizlilik Politikasını okudum ve kabul ediyorum. Kişisel verilerimin kan bağışı organizasyonu amacıyla işlenmesine izin veriyorum.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Kayıt Ol Butonu
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