import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareLocation = true;
  bool _shareProfile = true;
  bool _allowMessages = true;
  bool _showOnlineStatus = true;
  bool _dataAnalytics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Gizlilik Ayarları',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gizlilik Politikası Bilgisi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Veri Güvenliği',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verileriniz SSL şifreleme ile korunmaktadır. Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz ve sadece kan bağışı süreçlerinde kullanılır.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Konum Paylaşımı
            _buildSectionTitle('Konum ve Profil'),
            const SizedBox(height: 16),
            
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Konum Paylaşımı',
                subtitle: 'Yakındaki kan ihtiyaçlarını görmek için konumunuzu paylaşın',
                value: _shareLocation,
                onChanged: (value) {
                  setState(() {
                    _shareLocation = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.person_outline,
                title: 'Profil Görünürlüğü',
                subtitle: 'Profilinizin diğer kullanıcılar tarafından görülmesine izin verin',
                value: _shareProfile,
                onChanged: (value) {
                  setState(() {
                    _shareProfile = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.visibility_outlined,
                title: 'Çevrimiçi Durumu',
                subtitle: 'Çevrimiçi olduğunuzda diğer kullanıcılara gösterilsin',
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() {
                    _showOnlineStatus = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // İletişim ve Mesajlaşma
            _buildSectionTitle('İletişim'),
            const SizedBox(height: 16),
            
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.message_outlined,
                title: 'Mesaj Alma',
                subtitle: 'Diğer kullanıcılardan mesaj almaya izin verin',
                value: _allowMessages,
                onChanged: (value) {
                  setState(() {
                    _allowMessages = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Veri Analizi
            _buildSectionTitle('Veri Kullanımı'),
            const SizedBox(height: 16),
            
            _buildPrivacyCard([
              _buildSwitchTile(
                icon: Icons.analytics_outlined,
                title: 'Veri Analizi',
                subtitle: 'Uygulamayı geliştirmek için anonim kullanım verilerini paylaşın',
                value: _dataAnalytics,
                onChanged: (value) {
                  setState(() {
                    _dataAnalytics = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 32),
            
            // Veri Silme
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Hesap ve Veri Yönetimi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hesabınızı ve tüm verilerinizi kalıcı olarak silmek istiyorsanız destek ekibi ile iletişime geçin.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      _showDeleteAccountDialog();
                    },
                    child: Text(
                      'Hesabı Sil',
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPrivacyCard(List<Widget> children) {
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecektir. Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme talebi destek ekibine iletildi.'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}