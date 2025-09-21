import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // API key'i doğrudan buraya yazın (geçici olarak)
  static const String _apiKey = 'your_gemini_api_key_here';
  
  static Future<String> sendMessage(String userMessage) async {
    // API key kontrolü
    if (_apiKey.isEmpty || _apiKey == 'your_gemini_api_key_here') {
      print('⚠️ API key bulunamadı, mock response döndürülüyor');
      return _getSmartMockResponse(userMessage);
    }

    // Önce basit bir test yapalım
    try {
      print('🔄 API Test başlıyor...');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
      
      // Basit test endpoint'i
      final testUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey';
      
      final testBody = {
        'contents': [
          {
            'parts': [
              {'text': 'Merhaba, test mesajı'}
            ]
          }
        ]
      };

      print('📤 Test URL: ${testUrl.substring(0, 100)}...');

      final response = await http.post(
        Uri.parse(testUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(testBody),
      ).timeout(const Duration(seconds: 10));

      print('📥 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          print('✅ Gerçek AI yanıtı alındı!');
          
          // Şimdi gerçek soruyu sor
          return await _getRealResponse(userMessage);
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
    }

    // API çalışmıyorsa mock response
    print('🤖 Mock response kullanılıyor');
    return _getSmartMockResponse(userMessage);
  }

  static Future<String> _getRealResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Sen Can Bağı uygulamasının AI asistanısın. Kan bağışı konusunda uzman bir asistansın.

Kullanıcı sorusu: $userMessage

Lütfen Türkçe ve samimi bir dille cevap ver. Eğer selamlaşma yapıyorsa karşılık ver ve kendini tanıt.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 400,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'].toString().trim();
        }
      }
    } catch (e) {
      print('Real response error: $e');
    }
    
    return _getSmartMockResponse(userMessage);
  }

  static String _getSmartMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Selamlaşma
    if (message.contains('merhaba') || message.contains('selam') || message.contains('hello')) {
      return "Merhaba! 👋 Ben Can Bağı AI asistanınızım. Kan bağışı, kan grupları uyumluluğu ve acil durumlar hakkında size yardımcı olabilirim. Size nasıl yardımcı olabilirim? 🩸";
    }
    
    // A Rh+ kan grubu
    if (message.contains('a rh+') || message.contains('a+') || message.contains('arh+')) {
      return """A Rh+ kan grubu hakkında bilgi vereyim! 🩸

**A Rh+ kan grubu:**
• **Kime kan verebilir:** A+ ve AB+ kan gruplarına
• **Kimden kan alabilir:** A+, A-, O+, O- kan gruplarından

**Önemli bilgiler:**
• Türkiye'de yaklaşık %38 oranında görülür
• Rh+ olduğu için hem Rh+ hem Rh- alabilir
• Kan bağışı yapmak için ideal gruplardan biri

Başka sorularınız var mı? 😊""";
    }
    
    // Kan grubu uyumluluğu
    if (message.contains('kan grubu') || message.contains('uyumluluk')) {
      return """Kan grubu uyumluluğu hakkında bilgi vereyim! 🩸

**Temel kurallar:**
• **O Rh-:** Evrensel verici (herkese verebilir)
• **AB Rh+:** Evrensel alıcı (herkesten alabilir)
• **A grubu:** A ve AB gruplarına verebilir
• **B grubu:** B ve AB gruplarına verebilir
• **Rh+ olanlar:** Rh+ ve Rh- alabilir
• **Rh- olanlar:** Sadece Rh- alabilir

Hangi kan grubunuz hakkında detay istiyorsunuz?""";
    }
    
    // Kan bağışı
    if (message.contains('bağış') || message.contains('donate')) {
      return """Kan bağışı yapmak harika bir karar! 👏

**Kan bağışı şartları:**
• 18-65 yaş arası olmak
• En az 50 kg ağırlığında olmak
• Son 3 ayda kan bağışı yapmamış olmak
• Sağlıklı olmak
• Yeterli hemoglobin değerine sahip olmak

**Bağış öncesi:**
• Bol su için
• Yeterli uyku alın
• Hafif bir öğün tüketin

Başka merak ettikleriniz var mı? 🩸""";
    }
    
    // Acil durum
    if (message.contains('acil') || message.contains('emergency')) {
      return """🚨 **Acil kan ihtiyacı durumunda:**

1. **Hemen 112'yi arayın**
2. **En yakın hastaneye başvurun**
3. **Uygulamamızdan acil bildirim oluşturun**
4. **Kan merkezlerini arayın:**
   • Kızılay: 168
   • AKOM: 153

**Önemli:** Acil durumda zaman çok kritik! Önce tıbbi müdahale, sonra kan temini.

Size nasıl yardımcı olabilirim?""";
    }
    
    // Genel yardım
    return """Merhaba! Ben Can Bağı AI asistanınızım. 🤖

**Size yardımcı olabileceğim konular:**
• 🩸 Kan grubu uyumluluğu
• 💉 Kan bağışı süreci ve şartları
• 🚨 Acil kan ihtiyaçları
• 📍 Kan merkezi bilgileri
• ❓ Kan bağışı hakkında genel sorular

Hangi konuda yardım istiyorsunuz?""";
  }
}