import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    print('🔑 API Key durumu: ${key.isEmpty ? "BOŞ" : "DOLU (${key.length} karakter)"}');
    return key;
  }

  static Future<String> sendMessage(String message) async {
    print('📤 AI Service çağrıldı: $message');
    
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
      print('❌ API key bulunamadı, mock response döndürülüyor');
      return _getSmartMockResponse(message);
    }

    try {
      print('🌐 Gemini AI ile bağlantı kuruluyor...');
      
      // Gemini model'i oluştur
     // Gemini model'i oluştur
      final model = GenerativeModel(
       model: 'gemini-1.5-flash',  // veya 'gemini-1.5-pro', 'gemini-2.0-flash'
        apiKey: apiKey,
        );


      print('🤖 Gemini Pro model hazırlandı');

      // İçerik oluştur
      final content = [Content.text(message)];
      
      print('📝 İçerik hazırlandı, yanıt bekleniyor...');

      // Yanıt al
      final response = await model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ Gemini AI yanıtı alındı: ${response.text!.substring(0, 50)}...');
        return response.text!;
      } else {
        print('❌ Gemini AI boş yanıt döndürdü');
        throw Exception('Boş yanıt alındı');
      }
      
    } catch (e) {
      print('❌ Gemini AI hatası: $e');
      print('🔄 Mock response\'a geçiliyor...');
      return _getSmartMockResponse(message);
    }
  }

  static String _getSmartMockResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('merhaba') || lowerMessage.contains('selam') || lowerMessage.contains('hello')) {
      return '''Merhaba! Ben Can Bağı AI asistanınızım. Size nasıl yardımcı olabilirim?

🩸 Kan bağışı hakkında sorularınızı yanıtlayabilirim
🏥 Yakındaki sağlık tesislerini bulmanıza yardım edebilirim
📋 Kan grupları ve uyumluluk hakkında bilgi verebilirim
🚨 Acil durumlarda ne yapmanız gerektiğini söyleyebilirim

Ne öğrenmek istiyorsunuz?''';
    }
    
    if (lowerMessage.contains('a rh+') || lowerMessage.contains('a pozitif')) {
      return '''A Rh+ kan grubunuz hakkında bilgiler:

🩸 **Kan Bağışı:**
- A Rh+ ve AB Rh+ kan gruplarına bağış yapabilirsiniz
- Evrensel bağışçı değilsiniz, ancak yaygın bir kan grubu

🩸 **Kan Alma:**
- A Rh+, A Rh-, O Rh+, O Rh- kan gruplarından alabilirsiniz
- Acil durumlarda O Rh- (evrensel verici) kan alabilirsiniz

📊 **İstatistik:** Türkiye'de yaklaşık %38 oranında görülür

💡 **Tavsiye:** Düzenli kan bağışı yaparak hayat kurtarabilirsiniz!''';
    }
    
    if (lowerMessage.contains('kan grup') || lowerMessage.contains('uyumluluk')) {
      return '''Kan Grupları ve Uyumluluk Tablosu:

🅰️ **A Grubu:**
- A Rh+: A+, AB+ gruplarına verir | A+, A-, O+, O- gruplarından alır
- A Rh-: A+, A-, AB+, AB- gruplarına verir | A-, O- gruplarından alır

🅱️ **B Grubu:**
- B Rh+: B+, AB+ gruplarına verir | B+, B-, O+, O- gruplarından alır
- B Rh-: B+, B-, AB+, AB- gruplarına verir | B-, O- gruplarından alır

🆎 **AB Grubu:**
- AB Rh+: Sadece AB+ grubuna verir | Tüm gruplardan alır (Evrensel alıcı)
- AB Rh-: AB+, AB- gruplarına verir | AB-, A-, B-, O- gruplarından alır

⭕ **O Grubu:**
- O Rh+: A+, B+, AB+, O+ gruplarına verir | O+, O- gruplarından alır
- O Rh-: Tüm gruplara verir (Evrensel verici) | Sadece O- grubundan alır''';
    }
    
    if (lowerMessage.contains('bağış') || lowerMessage.contains('donate')) {
      return '''Kan Bağışı Hakkında Önemli Bilgiler:

✅ **Bağış Şartları:**
- 18-65 yaş arası
- En az 50 kg ağırlık
- Son bağıştan 8 hafta geçmiş olmalı
- Sağlıklı ve dinlenmiş olmalısınız

🚫 **Bağış Yapamayacağınız Durumlar:**
- Grip, soğuk algınlığı
- Antibiyotik kullanımı
- Son 6 ay içinde ameliyat
- Hamilelik ve emzirme dönemi

📅 **Bağış Süreci:**
1. Kayıt ve ön muayene (15 dk)
2. Kan alma işlemi (8-10 dk)
3. Dinlenme ve ikram (15 dk)

💪 **Faydaları:**
- Bir ünite kan 3 kişinin hayatını kurtarabilir
- Düzenli bağış sağlığınıza da faydalıdır
- Ücretsiz sağlık kontrolü imkanı''';
    }
    
    if (lowerMessage.contains('acil') || lowerMessage.contains('emergency')) {
      return '''🚨 ACİL KAN İHTİYACI DURUMUNDA:

📞 **Hemen Yapılacaklar:**
1. 112 Acil Servisi arayın
2. En yakın hastaneye gidin
3. Can Bağı uygulamasından acil ilan oluşturun

🏥 **Hastanede:**
- Kan grubu testi yapılacak
- Çapraz eşleştirme (cross-match) yapılacak
- Acil kan ihtiyacı bildirimi yapılacak

📱 **Can Bağı Uygulaması:**
- Konum bazlı bağışçı arama
- Anlık bildirim sistemi
- Hızlı iletişim imkanı

⚡ **Kritik Bilgi:**
- O Rh- evrensel verici (acil durumlarda herkese verilebilir)
- AB Rh+ evrensel alıcı (tüm kan gruplarından alabilir)
- Kan bulma süresi ortalama 2-4 saat

Acil durumda panik yapmayın, sistematik hareket edin!''';
    }
    
    return '''Merhaba! Can Bağı AI asistanınızım. Size şu konularda yardımcı olabilirim:

🩸 **Kan Bağışı:** Bağış şartları, süreç, faydalar
🏥 **Sağlık Tesisleri:** Yakındaki hastane ve kan merkezleri
📋 **Kan Grupları:** Uyumluluk tablosu ve bilgiler
🚨 **Acil Durumlar:** Ne yapılması gerektiği
💡 **Genel Bilgi:** Kan bağışı hakkında merak ettikleriniz

Hangi konuda yardım istiyorsunuz?''';
  }
}