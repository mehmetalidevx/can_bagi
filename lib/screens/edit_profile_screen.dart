import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _selectedBloodType;
  String? _selectedGender;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;
  
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
  
  final List<String> _genders = ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) throw Exception('Kullanıcı oturumu bulunamadı');
      
      final userData = await AuthService.getUserData(user.uid);
      if (userData != null && mounted) {
        setState(() {
          _nameController.text = userData['fullName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _cityController.text = userData['city'] ?? '';
          _districtController.text = userData['district'] ?? '';
          _weightController.text = userData['weight']?.toString() ?? '';
          _selectedBloodType = userData['bloodType'];
          _selectedGender = userData['gender'];
          // Firestore Timestamp'i DateTime'a çevirme
          if (userData['birthDate'] != null) {
            if (userData['birthDate'] is DateTime) {
              _selectedBirthDate = userData['birthDate'] as DateTime;
            } else {
              // Firestore Timestamp durumu için
              _selectedBirthDate = (userData['birthDate'] as dynamic).toDate();
            }
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        print('Kullanıcı verileri yüklenirken hata: $e');
        // Hata mesajını gösterme - sessizce geç
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Profil bilgileri yükleniyor...'),
        //     backgroundColor: Colors.orange,
        //     duration: Duration(seconds: 1),
        //   ),
        // );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 6570)), // ~18 yaş
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    setState(() {
      _isLoading = true;
    });

    try {
      final weight = double.tryParse(_weightController.text.trim());
      if (weight == null || weight <= 0) {
        throw Exception('Geçerli bir kilo değeri girin');
      }

      // Mevcut kullanıcının UID'sini al
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await AuthService.updateUserData(user.uid, {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'weight': weight,
        'bloodType': _selectedBloodType!,
        'gender': _selectedGender!,
        'birthDate': _selectedBirthDate!,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil bilgileri başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme hatası: $e'),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Profil Bilgilerini Düzenle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil Fotoğrafı
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen adınızı ve soyadınızı girin';
                          }
                          if (value.trim().length < 2) {
                            return 'Ad soyad en az 2 karakter olmalıdır';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Email değiştirilemez
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'ornek@email.com',
                        ),
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen telefon numaranızı girin';
                          }
                          // Basit telefon numarası kontrolü
                          final phoneRegex = RegExp(r'^[0-9+\-\s\(\)]+$');
                          if (!phoneRegex.hasMatch(value.trim())) {
                            return 'Geçerli bir telefon numarası girin';
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
                                if (value == null || value.trim().isEmpty) {
                                  return 'Şehir gerekli';
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
                                if (value == null || value.trim().isEmpty) {
                                  return 'İlçe gerekli';
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen kilonuzu girin';
                          }
                          final weight = double.tryParse(value.trim());
                          if (weight == null || weight <= 0 || weight > 300) {
                            return 'Geçerli kilo girin (1-300 kg)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Kan Grubu
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
                        'Kan Grubu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
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
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? bloodType['color'] : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? bloodType['color'] : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    bloodType['icon'],
                                    color: isSelected ? Colors.white : bloodType['color'],
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bloodType['type'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Güncelle Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Profil Bilgilerini Güncelle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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