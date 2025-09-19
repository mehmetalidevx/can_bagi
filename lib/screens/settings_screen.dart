import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  bool _emergencyAlertsEnabled = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedBloodType = 'A Rh+';
  
  final List<String> _languages = ['Türkçe', 'English', 'العربية'];
  final List<String> _bloodTypes = ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-'];

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
      body: SingleChildScrollView(
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
                subtitle: 'Kişisel bilgilerinizi düzenleyin',
                onTap: () => _showProfileDialog(),
              ),
              _buildDropdownTile(
                icon: Icons.water_drop_outlined,
                title: 'Kan Grubu',
                value: _selectedBloodType,
                items: _bloodTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value!;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 16),
            
            // Bildirim Ayarları
            _buildSectionHeader('Bildirim Ayarları'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                subtitle: 'Acil kan ihtiyacı bildirimleri',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.emergency_outlined,
                title: 'Acil Uyarılar',
                subtitle: 'Kritik kan ihtiyaçları için anında bildirim',
                value: _emergencyAlertsEnabled,
                onChanged: (value) {
                  setState(() {
                    _emergencyAlertsEnabled = value;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 16),
            
            // Uygulama Ayarları
            _buildSectionHeader('Uygulama Ayarları'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Konum Servisleri',
                subtitle: 'Yakındaki kan ihtiyaçlarını görmek için',
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Karanlık Tema',
                subtitle: 'Gece modu aktif/pasif',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                    AppTheme.toggleTheme();
                  });
                },
              ),
              _buildDropdownTile(
                icon: Icons.language_outlined,
                title: 'Dil',
                value: _selectedLanguage,
                items: _languages,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ]),
            
            const SizedBox(height: 16),
            
            // Güvenlik ve Gizlilik
            _buildSectionHeader('Güvenlik ve Gizlilik'),
            _buildSettingsCard([
              _buildProfileTile(
                icon: Icons.security_outlined,
                title: 'Gizlilik Ayarları',
                subtitle: 'Veri paylaşımı ve gizlilik',
                onTap: () => _showPrivacyDialog(),
              ),
              _buildProfileTile(
                icon: Icons.lock_outline,
                title: 'Şifre Değiştir',
                subtitle: 'Hesap güvenliğinizi artırın',
                onTap: () => _showPasswordDialog(),
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
                onTap: () => _showHelpDialog(),
              ),
              _buildProfileTile(
                icon: Icons.info_outline,
                title: 'Uygulama Hakkında',
                subtitle: 'Versiyon 1.0.0',
                onTap: () => _showAboutDialog(),
              ),
              _buildProfileTile(
                icon: Icons.star_outline,
                title: 'Uygulamayı Değerlendir',
                subtitle: 'App Store\'da puan verin',
                onTap: () => _rateApp(),
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

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Bilgileri'),
        content: const Text('Profil düzenleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Ayarları'),
        content: const Text('Verileriniz güvenli bir şekilde saklanmaktadır. Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: const Text('Şifre değiştirme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yardım ve Destek'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sıkça Sorulan Sorular:'),
            SizedBox(height: 8),
            Text('• Nasıl kan bağışı yapabilirim?'),
            Text('• Kan grubu uyumluluğu nedir?'),
            Text('• Acil durumlarda ne yapmalıyım?'),
            SizedBox(height: 16),
            Text('İletişim: destek@canbagi.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Can Bağı',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.favorite,
        color: AppTheme.primaryColor,
        size: 48,
      ),
      children: const [
        Text('Kan bağışçıları ve ihtiyaç sahiplerini buluşturan sosyal sorumluluk uygulaması.'),
        SizedBox(height: 16),
        Text('Hackathon 2024 projesi olarak geliştirilmiştir.'),
      ],
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App Store\'a yönlendiriliyorsunuz...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}