import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  // Firebase başlatma kontrolü
  static Future<void> _ensureInitialized() async {
    try {
      if (Firebase.apps.isEmpty) {
        print('🔄 Firebase başlatılıyor...');
        await Firebase.initializeApp();
        print('✅ Firebase başlatıldı');
      }
      _auth ??= FirebaseAuth.instance;
      _firestore ??= FirebaseFirestore.instance;
    } catch (e) {
      print('❌ Firebase başlatma hatası: $e');
      rethrow;
    }
  }

  // Mevcut kullanıcıyı al
  static Future<User?> getCurrentUser() async {
    await _ensureInitialized();
    return _auth?.currentUser;
  }

  // Auth state stream
  static Stream<User?> get authStateChanges {
    return _auth?.authStateChanges() ?? const Stream.empty();
  }

  // Email ile kayıt ol
  static Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String bloodType,
    required String phone,
    required String city,
    required String district,
    required String gender,
    required DateTime birthDate,
    required double weight,
  }) async {
    try {
      print('🔄 Firebase başlatma kontrolü yapılıyor...');
      await _ensureInitialized();
      
      print('🔄 Kullanıcı kaydı başlatılıyor...');
      UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔄 Kullanıcı bilgileri Firestore\'a kaydediliyor...');
      // Kullanıcı bilgilerini Firestore'a kaydet
      await _firestore!.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'fullName': fullName,
        'bloodType': bloodType,
        'phone': phone,
        'city': city,
        'district': district,
        'gender': gender,
        'birthDate': birthDate.toIso8601String(),
        'weight': weight,
        'createdAt': FieldValue.serverTimestamp(),
        'isAvailable': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      print('✅ Kullanıcı başarıyla kaydedildi!');
      return result;
    } catch (e) {
      print('❌ Kayıt hatası: $e');
      return null;
    }
  }

  // Email ile giriş yap
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _ensureInitialized();
      
      UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Son görülme zamanını güncelle
      await _firestore!.collection('users').doc(result.user!.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });

      return result;
    } catch (e) {
      print('Giriş hatası: $e');
      return null;
    }
  }

  // Çıkış yap
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _auth!.signOut();
    } catch (e) {
      print('Çıkış hatası: $e');
    }
  }

  // Şifre sıfırlama
  static Future<bool> resetPassword(String email) async {
    try {
      await _ensureInitialized();
      await _auth!.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  // Kullanıcı bilgilerini al
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      await _ensureInitialized();
      DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Kullanıcı bilgisi alma hatası: $e');
      return null;
    }
  }

  // Kullanıcı bilgilerini güncelle
  static Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _ensureInitialized();
      await _firestore!.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Kullanıcı bilgisi güncelleme hatası: $e');
      return false;
    }
  }

  // Şifre değiştirme
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _ensureInitialized();
      
      User? user = _auth!.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Kullanıcı oturumu bulunamadı'
        };
      }

      // Mevcut şifreyi doğrula
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Kullanıcıyı yeniden doğrula
      await user.reauthenticateWithCredential(credential);
      
      // Yeni şifreyi ayarla
      await user.updatePassword(newPassword);
      
      return {
        'success': true,
        'message': 'Şifreniz başarıyla değiştirildi'
      };
      
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Mevcut şifreniz yanlış';
          break;
        case 'weak-password':
          message = 'Yeni şifre çok zayıf';
          break;
        case 'requires-recent-login':
          message = 'Güvenlik nedeniyle tekrar giriş yapmanız gerekiyor';
          break;
        default:
          message = 'Şifre değiştirme işlemi başarısız: ${e.message}';
      }
      
      return {
        'success': false,
        'message': message
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Beklenmeyen bir hata oluştu: $e'
      };
    }
  }
  
  // Hesap silme işlemi
  static Future<bool> deleteAccount() async {
    try {
      await _ensureInitialized();
      // Mevcut kullanıcıyı al
      final user = _auth?.currentUser;
      
      if (user != null) {
        // Kullanıcının Firestore verilerini sil
        await _firestore?.collection('users').doc(user.uid).delete();
        
        // Firebase Authentication hesabını sil
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Hesap silinirken hata: $e');
      
      // Eğer yeniden kimlik doğrulama gerekiyorsa
      if (e.toString().contains('requires-recent-login')) {
        throw Exception('Güvenlik nedeniyle hesabınızı silmek için önce çıkış yapıp tekrar giriş yapmanız gerekiyor.');
      }
      
      throw Exception('Hesap silinirken bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }

  // Yeniden kimlik doğrulama ile hesap silme
  static Future<bool> deleteAccountWithReauth(String password) async {
    try {
      await _ensureInitialized();
      final user = _auth?.currentUser;
      
      if (user != null && user.email != null) {
        // Yeniden kimlik doğrulama
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Kullanıcının Firestore verilerini sil
        await _firestore?.collection('users').doc(user.uid).delete();
        
        // Firebase Authentication hesabını sil
        await user.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Hesap silinirken hata: $e');
      throw Exception('Hesap silinirken bir hata oluştu. Şifrenizi kontrol edin.');
    }
  }
}