import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Gizlilik Politikası',
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
            // Veri Güvenliği
            _buildInfoCard(
              icon: Icons.security,
              title: 'Veri Güvenliği',
              content: 'Verileriniz SSL şifreleme ile korunmaktadır. Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz ve sadece kan bağışı süreçlerinde kullanılır.',
            ),
            
            const SizedBox(height: 16),
            
            // Konum Bilgileri
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Konum Bilgileri',
              content: 'Konum bilgileriniz sadece yakındaki acil kan ihtiyaçlarını göstermek için kullanılır. Tam adresiniz paylaşılmaz, sadece genel bölge bilgisi kullanılır.',
            ),
            
            const SizedBox(height: 16),
            
            // Kişisel Veriler
            _buildInfoCard(
              icon: Icons.person,
              title: 'Kişisel Veriler',
              content: 'Ad, soyad, kan grubu ve iletişim bilgileriniz sadece acil durumlarda uygun bağışçıları bulmak için kullanılır. Bu bilgiler şifrelenmiş olarak saklanır.',
            ),
            
            const SizedBox(height: 16),
            
            // Veri Paylaşımı
            _buildInfoCard(
              icon: Icons.share,
              title: 'Veri Paylaşımı',
              content: 'Verileriniz hiçbir şekilde ticari amaçlarla kullanılmaz veya satılmaz. Sadece kan bağışı koordinasyonu için gerekli minimum bilgiler paylaşılır.',
            ),
            
            const SizedBox(height: 16),
            
            // KVKK Uyumu
            _buildInfoCard(
              icon: Icons.gavel,
              title: 'KVKK Uyumu',
              content: 'Uygulamamız Kişisel Verilerin Korunması Kanunu (KVKK) hükümlerine uygun olarak geliştirilmiştir. Verilerinizi istediğiniz zaman silebilir veya güncelleyebilirsiniz.',
            ),
            
            const SizedBox(height: 16),
            
            // İletişim
            _buildInfoCard(
              icon: Icons.contact_support,
              title: 'Veri Hakları',
              content: 'Kişisel verilerinizle ilgili sorularınız için destek ekibimizle iletişime geçebilirsiniz. Verilerinizi silme, güncelleme veya kopyasını alma hakkınız bulunmaktadır.',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}