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
}