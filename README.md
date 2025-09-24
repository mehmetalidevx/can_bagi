# 🩸 Can Bağı - Kan Bağışı Uygulaması

**Hackathon 2025 Projesi**

Can Bağı, acil kan ihtiyacı durumunda bağışçıları ve hastaneleri buluşturan, hayat kurtaran bir mobil uygulamadır. Flutter ile geliştirilmiş, Firebase backend altyapısı kullanan modern bir kan bağışı platformudur.

## 🌐 Proje Linkleri

- **GitHub Repository**: [https://github.com/mehmetalidevx/can_bagi](https://github.com/mehmetalidevx/can_bagi)
- **Web Admin Panel**: Firebase Hosting üzerinde deploy edilmiş web arayüzü

## 📱 Uygulama Özellikleri

### 🔐 Kullanıcı Yönetimi
- **Güvenli Kayıt/Giriş**: Firebase Authentication ile güvenli kullanıcı yönetimi
- **Profil Yönetimi**: Kan grubu, kişisel bilgiler ve iletişim bilgileri güncelleme
- **Şifre Yönetimi**: Şifre değiştirme ve şifremi unuttum özellikleri
- **Hesap Güvenliği**: Re-authentication ile güvenli hesap silme

### 🗺️ Harita ve Konum
- **Interaktif Harita**: Google Maps entegrasyonu ile kan bağışı merkezlerini görüntüleme
- **Konum Servisleri**: Gerçek zamanlı konum tabanlı hizmetler
- **Yakındaki Merkezler**: En yakın kan bağışı merkezlerini bulma
- **Harita Kontrolü**: Zoom, pan ve marker etkileşimleri

### 🚨 Acil Durum Sistemi
- **Acil Kan İhtiyacı**: Hızlı kan talebi oluşturma sistemi
- **Anlık Bildirimler**: Firebase Cloud Messaging ile push notification
- **Kan Grubu Eşleştirme**: Uyumlu kan gruplarını otomatik eşleştirme
- **Bildirim Geçmişi**: Geçmiş bildirimleri görüntüleme ve yönetme

### 🤖 Yapay Zeka Asistanı
- **AI Chat**: Google Generative AI ile kan bağışı hakkında sorular
- **Akıllı Öneriler**: Kişiselleştirilmiş kan bağışı önerileri
- **7/24 Destek**: Yapay zeka destekli müşteri hizmetleri
- **Sohbet Geçmişi**: AI ile yapılan konuşmaları kaydetme

### 📊 Admin Paneli (Web & Mobile)
- **Web Admin Interface**: Firebase Hosting üzerinde çalışan web tabanlı admin paneli
- **Bildirim Yönetimi**: Toplu bildirim gönderme ve yönetme
- **Kullanıcı Yönetimi**: Kullanıcı verilerini görüntüleme ve yönetme
- **İstatistikler**: Kan bağışı istatistikleri ve detaylı raporlar
- **Talep Yönetimi**: Bekleyen, onaylanan ve reddedilen talepleri yönetme
- **Dashboard Analytics**: Gerçek zamanlı veri görselleştirme
- **Admin Authentication**: Özel admin giriş sistemi

### ⚙️ Ayarlar ve Kişiselleştirme
- **Profil Düzenleme**: Kişisel bilgileri güncelleme
- **Gizlilik Ayarları**: Veri gizliliği ve güvenlik bilgileri
- **Kan Grubu Yönetimi**: Kan grubu seçimi ve uyumluluk bilgileri
- **Hesap Güvenliği**: Şifre değiştirme ve hesap silme
- **Yardım ve Destek**: Kullanıcı rehberi ve destek sistemi

### 🔔 Bildirim Sistemi
- **Push Notifications**: Firebase Cloud Messaging entegrasyonu
- **Bildirim Geçmişi**: Geçmiş bildirimleri görüntüleme
- **Özelleştirilebilir Bildirimler**: Kullanıcı tercihlerine göre bildirim ayarları

## 🛠️ Teknoloji Stack

### Frontend
- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Dart**: Programlama dili
- **Material Design**: Modern ve kullanıcı dostu arayüz tasarımı
- **Flutter Web**: Web admin paneli için responsive web arayüzü

### Backend & Servisler
- **Firebase Authentication**: Kullanıcı kimlik doğrulama ve güvenlik
- **Cloud Firestore**: NoSQL veritabanı ve gerçek zamanlı veri senkronizasyonu
- **Firebase Cloud Messaging**: Push notification servisi
- **Firebase Hosting**: Web admin paneli hosting
- **Google Maps API**: Harita ve konum servisleri
- **Google Generative AI**: Yapay zeka chat sistemi
- **Geolocator**: Konum servisleri ve izin yönetimi

### Bağımlılıklar
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.17.9
  cloud_firestore: ^4.15.9
  firebase_messaging: ^14.7.20
  google_generative_ai: ^0.4.3
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
  flutter_localizations:
    sdk: flutter
```

## 🚀 Kurulum ve Çalıştırma

### Ön Gereksinimler
- Flutter SDK (3.7.2+)
- Dart SDK
- Android Studio / VS Code
- Firebase projesi
- Google Maps API anahtarı
- Google AI API anahtarı

### Kurulum Adımları

1. **Projeyi klonlayın**
```bash
git clone https://github.com/mehmetalidevx/can_bagi.git
cd can_bagi
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Environment dosyasını oluşturun**
```bash
# .env dosyası oluşturun ve aşağıdaki anahtarları ekleyin
GOOGLE_AI_API_KEY=your_google_ai_api_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

4. **Firebase yapılandırması**
- `android/app/google-services.json` dosyasını ekleyin
- `ios/Runner/GoogleService-Info.plist` dosyasını ekleyin
- Firebase Console'da Authentication, Firestore ve Cloud Messaging'i etkinleştirin

5. **Uygulamayı çalıştırın**
```bash
# Mobil uygulama için
flutter run

# Web admin paneli için
flutter run -d chrome --web-port=8080
```

## 📱 Platform Desteği

- ✅ **Android**: Tam destek (API 21+)
- ✅ **iOS**: Tam destek (iOS 12+)
- ✅ **Web**: Firebase Hosting ile deploy edilmiş admin paneli
- ⚠️ **Desktop**: Sınırlı destek (Windows, macOS, Linux)

## 🌐 Web Admin Panel

Web admin paneli, Firebase Hosting üzerinde çalışan responsive bir web uygulamasıdır:

### Özellikler
- **Responsive Design**: Tüm cihazlarda uyumlu çalışır
- **Real-time Dashboard**: Canlı veri görselleştirme
- **User Management**: Kullanıcı hesaplarını yönetme
- **Notification Center**: Toplu bildirim gönderme
- **Analytics**: Detaylı istatistikler ve raporlar
- **Admin Authentication**: Güvenli admin girişi

### Erişim

**Live Demo**: Proje canlı demo linki (https://can-bagi.web.app/admin)

- Web admin paneline `/admin` route'u ile erişilebilir
- Admin hesabı ile giriş yapılması gerekir
- Firebase Authentication ile korunmuştur

## 🔧 Geliştirme

### Proje Yapısı
