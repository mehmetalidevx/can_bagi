import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/screens/change_password_screen.dart';
import 'package:can_bagi/screens/edit_profile_screen.dart';
import 'package:can_bagi/screens/privacy_settings_screen.dart';
import 'package:can_bagi/screens/help_support_screen.dart';
import 'package:can_bagi/services/auth_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedBloodType = 'A Rh+';
  String _userName = 'Kullanıcı Adı';
  String _userEmail = 'kullanici@email.com';
  String _userPhone = '+90 555 123 45 67';
  bool _isLoading = true;
  
  final List<String> _bloodTypes = ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Güvenlik için 10 saniye sonra loading'i bitir
    Timer(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      
      if (user != null) {
        final userData = await AuthService.getUserData(user.uid);
        if (userData != null && mounted) {
          setState(() {
            _userName = userData['fullName'] ?? 'Kullanıcı Adı';
            _userEmail = userData['email'] ?? user.email ?? 'kullanici@email.com';
            _userPhone = userData['phone'] ?? '+90 555 123 45 67';
            _selectedBloodType = userData['bloodType'] ?? 'A Rh+';
            _isLoading = false;
          });
        } else {
          // Kullanıcı verisi bulunamadı, varsayılan değerlerle devam et
          if (mounted) {
            setState(() {
              _userName = 'Kullanıcı Adı';
              _userEmail = user.email ?? 'kullanici@email.com';
              _userPhone = '+90 555 123 45 67';
              _selectedBloodType = 'A Rh+';
              _isLoading = false;
            });
          }
        }
      } else {
        // Kullanıcı oturumu yok, varsayılan değerlerle devam et
        if (mounted) {
          setState(() {
            _userName = 'Kullanıcı Adı';
            _userEmail = 'kullanici@email.com';
            _userPhone = '+90 555 123 45 67';
            _selectedBloodType = 'A Rh+';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Hata durumunda da loading'i bitir
      if (mounted) {
        setState(() {
          _userName = 'Kullanıcı Adı';
          _userEmail = 'kullanici@email.com';
          _userPhone = '+90 555 123 45 67';
          _selectedBloodType = 'A Rh+';
          _isLoading = false;
        });
        print('Kullanıcı verileri yüklenirken hata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil Ayarları
                  _buildSectionHeader('Profil Ayarları'),
                  _buildSettingsCard([
                    _buildProfileTile(
                      icon: Icons.person_outline,
                      title: 'Profil Bilgileri',
                      subtitle: _userName,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        _loadUserData();
                      },
                    ),
                    _buildDropdownTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Kan Grubu',
                      value: _selectedBloodType,
                      items: _bloodTypes,
                      onChanged: (value) async {
                        setState(() {
                          _selectedBloodType = value!;
                        });
                        
                        try {
                          final user = await AuthService.getCurrentUser();
                          if (user != null) {
                            await AuthService.updateUserData(user.uid, {
                              'bloodType': _selectedBloodType,
                            });
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kan grubu güncellendi'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Kan grubu güncellenirken hata: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Uygulama Ayarları
                
                  
                  const SizedBox(height: 16),
                  
                  // Güvenlik ve Gizlilik
                  _buildSectionHeader('Güvenlik ve Gizlilik'),
                  _buildSettingsCard([
                    _buildProfileTile(
                      icon: Icons.security_outlined,
                      title: 'Gizlilik Ayarları',
                      subtitle: 'Veri güvenliği ve gizlilik politikası',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacySettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Hesap Ayarları
                  _buildSectionHeader('Hesap Ayarları'),
                  _buildSettingsCard([
                    _buildProfileTile(
                      icon: Icons.lock_outline,
                      title: 'Şifre Değiştir',
                      subtitle: '••••••••',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileTile(
                      icon: Icons.delete_forever,
                      title: 'Hesabı Sil',
                      subtitle: 'Bu işlem geri alınamaz',
                      onTap: _showDeleteAccountDialog,
                      textColor: AppTheme.errorColor,
                      iconColor: AppTheme.errorColor,
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  // Destek ve Bilgi
                  _buildSectionHeader('Destek ve Bilgi'),
                  _buildSettingsCard([
                    _buildProfileTile(
                      icon: Icons.help_outline,
                      title: 'Yardım ve Destek',
                      subtitle: 'SSS ve iletişim',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileTile(
                      icon: Icons.info_outline,
                      title: 'Uygulama Hakkında',
                      subtitle: 'Versiyon 1.0.0',
                      onTap: () => _showAboutDialog(),
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.primaryColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Hesap silme onay dialogu
  Future<void> _showDeleteAccountDialog() async {
    final TextEditingController passwordController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Hesabınızı silmek istediğinizden emin misiniz?'),
                const SizedBox(height: 10),
                const Text('Bu işlem geri alınamaz ve tüm verileriniz silinecektir.', 
                  style: TextStyle(color: AppTheme.errorColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifrenizi girin',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hesabımı Sil', 
                style: TextStyle(color: AppTheme.errorColor)),
              onPressed: () async {
                if (passwordController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _deleteAccountWithPassword(passwordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen şifrenizi girin'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Şifre ile hesap silme işlemi
  Future<void> _deleteAccountWithPassword(String password) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await AuthService.deleteAccountWithReauth(password);
      
      if (result && mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesabınız başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Hesap silindikten sonra giriş ekranına git ve tüm önceki sayfaları temizle
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // Eski hesap silme fonksiyonunu kaldır
  // Future<void> _deleteAccount() async { ... }

  // Diğer fonksiyonlar için implementasyonlar
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.favorite, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text('Can Bağı'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Can Bağı - Kan Bağışı Uygulaması'),
                SizedBox(height: 8),
                Text('Versiyon: 1.0.0'),
                SizedBox(height: 8),
                Text('Bu uygulama kan bağışçıları ve ihtiyaç sahiplerini bir araya getirmek için geliştirilmiştir.'),
                SizedBox(height: 8),
                Text('Geliştirici: Can Bağı Ekibi'),
                SizedBox(height: 8),
                Text('© 2024 Can Bağı. Tüm hakları saklıdır.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}