import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Yardım ve Destek',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sıkça Sorulan Sorular
            _buildSectionHeader('Sıkça Sorulan Sorular'),
            _buildFAQCard([
              _buildExpansionTile(
                'Nasıl kan bağışı yapabilirim?',
                'Kan bağışı yapmak için:\n\n'
                '• 18-65 yaş arasında olmalısınız\n'
                '• En az 50 kg ağırlığında olmalısınız\n'
                '• Son 3 ay içinde kan bağışı yapmamış olmalısınız\n'
                '• Sağlıklı olmalısınız\n\n'
                'En yakın kan merkezine başvurabilir veya uygulama üzerinden acil ihtiyaçları görebilirsiniz.',
                Icons.bloodtype,
              ),
              _buildExpansionTile(
                'Kan grubu uyumluluğu nasıl çalışır?',
                'Kan grubu uyumluluğu:\n\n'
                '• O- kan grubu herkese kan verebilir (evrensel verici)\n'
                '• AB+ kan grubu herkesten kan alabilir (evrensel alıcı)\n'
                '• A kan grubu A ve AB kan gruplarına verebilir\n'
                '• B kan grubu B ve AB kan gruplarına verebilir\n'
                '• Rh+ kan grubu Rh+ kişilere verebilir\n'
                '• Rh- kan grubu hem Rh+ hem Rh- kişilere verebilir',
                Icons.compare_arrows,
              ),
              _buildExpansionTile(
                'Acil durumlarda ne yapmalıyım?',
                'Acil durumlar için:\n\n'
                '• "Acil İhtiyaç" sekmesinden bildirim oluşturun\n'
                '• Gerekli bilgileri eksiksiz doldurun\n'
                '• Konum bilginizi paylaşın\n'
                '• Yakındaki uyumlu bağışçılar otomatik bilgilendirilir\n'
                '• Acil durumlarda 112\'yi aramayı unutmayın',
                Icons.emergency,
              ),
              _buildExpansionTile(
                'Bildirimlerim nasıl çalışır?',
                'Bildirim sistemi:\n\n'
                '• Yakınınızdaki acil ihtiyaçlar için bildirim alırsınız\n'
                '• Kan grubunuza uygun istekler öncelikli gösterilir\n'
                '• Bildirim ayarlarınızı istediğiniz zaman değiştirebilirsiniz\n'
                '• Konum servislerini açık tutmanız önerilir',
                Icons.notifications_active,
              ),
              _buildExpansionTile(
                'Hesabımı nasıl güncellerim?',
                'Hesap güncelleme:\n\n'
                '• Ayarlar > Profil Düzenle\'ye gidin\n'
                '• Kişisel bilgilerinizi güncelleyin\n'
                '• Kan grubu bilginizi doğru girdiğinizden emin olun\n'
                '• İletişim bilgilerinizi güncel tutun\n'
                '• Değişiklikleri kaydetmeyi unutmayın',
                Icons.person_outline,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Güvenlik ve Gizlilik
            _buildSectionHeader('Güvenlik ve Gizlilik'),
            _buildFAQCard([
              _buildExpansionTile(
                'Verilerim güvende mi?',
                'Veri güvenliği:\n\n'
                '• Tüm verileriniz şifrelenmiş olarak saklanır\n'
                '• Kişisel bilgileriniz üçüncü taraflarla paylaşılmaz\n'
                '• Sadece acil durumlarda gerekli bilgiler paylaşılır\n'
                '• KVKK\'ya uygun veri işleme politikamız vardır\n'
                '• İstediğiniz zaman hesabınızı silebilirsiniz',
                Icons.security,
              ),
              _buildExpansionTile(
                'Konum bilgim nasıl kullanılır?',
                'Konum kullanımı:\n\n'
                '• Sadece yakındaki acil ihtiyaçları göstermek için kullanılır\n'
                '• Tam adresiniz paylaşılmaz, sadece genel bölge bilgisi\n'
                '• Konum servislerini istediğiniz zaman kapatabilirsiniz\n'
                '• Geçmiş konum verileriniz saklanmaz',
                Icons.location_on,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Teknik Destek
            _buildSectionHeader('Teknik Destek'),
            _buildFAQCard([
              _buildExpansionTile(
                'Uygulama çalışmıyor, ne yapmalıyım?',
                'Teknik sorunlar için:\n\n'
                '• Uygulamayı kapatıp yeniden açın\n'
                '• Telefonunuzu yeniden başlatın\n'
                '• Uygulama güncellemesi var mı kontrol edin\n'
                '• İnternet bağlantınızı kontrol edin\n'
                '• Sorun devam ederse destek ekibimizle iletişime geçin',
                Icons.build,
              ),
              _buildExpansionTile(
                'Bildirimler gelmiyor',
                'Bildirim sorunları:\n\n'
                '• Telefon ayarlarından bildirim izinlerini kontrol edin\n'
                '• Uygulama içi bildirim ayarlarını kontrol edin\n'
                '• "Rahatsız Etme" modunun kapalı olduğundan emin olun\n'
                '• Uygulamayı arka planda çalışmaya izin verin',
                Icons.notifications_off,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // İletişim Bilgileri
            _buildSectionHeader('İletişim Kanalları'),
            _buildContactCard(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildFAQCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildExpansionTile(String question, String answer, IconData icon) {
    return ExpansionTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: 24,
      ),
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildContactItem(
              Icons.email_outlined,
              'E-posta Desteği',
              'destek@canbagi.com',
              '7/24 e-posta desteği',
            ),
            const Divider(height: 24),
            _buildContactItem(
              Icons.phone_outlined,
              'Telefon Desteği',
              '+90 555 CAN BAGI',
              'Hafta içi 09:00 - 18:00',
            ),
            const Divider(height: 24),
            _buildContactItem(
              Icons.chat_outlined,
              'Canlı Destek',
              'Uygulama içi chat',
              'Hafta içi 09:00 - 22:00',
            ),
            const Divider(height: 24),
            _buildContactItem(
              Icons.web_outlined,
              'Web Sitesi',
              'www.canbagi.com',
              'Detaylı bilgi ve kaynaklar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String contact, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contact,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}