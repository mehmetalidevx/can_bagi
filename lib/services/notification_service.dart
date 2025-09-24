import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Bildirim oluştur
  static Future<String?> createNotification({
    required String bloodType,
    required String urgency,
    required String location,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    print('🔄 NotificationService.createNotification başladı');
    
    try {
      print('👤 Kullanıcı kontrolü yapılıyor...');
      final user = _auth.currentUser;
      print('👤 Mevcut kullanıcı: ${user?.uid}');
      print('📧 Kullanıcı email: ${user?.email}');
      
      if (user == null) {
        print('❌ Hata: Kullanıcı giriş yapmamış');
        return null;
      }

      print('📊 Kullanıcı verisi alınıyor...');
      // Kullanıcı bilgilerini al
      final userData = await _firestore.collection('users').doc(user.uid).get();
      print('📊 Kullanıcı verisi var mı: ${userData.exists}');
      
      if (!userData.exists) {
        print('⚠️ Kullanıcı verisi bulunamadı, varsayılan isim kullanılacak');
      }
      
      final userName = userData.data()?['fullName'] ?? 'Bilinmeyen Kullanıcı';
      print('👤 Kullanıcı adı: $userName');

      print('💾 Firestore\'a bildirim ekleniyor...');
      print('📝 Eklenecek veri:');
      print('  - userId: ${user.uid}');
      print('  - userName: $userName');
      print('  - bloodType: $bloodType');
      print('  - urgency: $urgency');
      print('  - location: $location');
      print('  - description: $description');
      print('  - latitude: $latitude');
      print('  - longitude: $longitude');
      
      final docRef = await _firestore.collection('notifications').add({
        'userId': user.uid,
        'userName': userName,
        'bloodType': bloodType,
        'urgency': urgency,
        'location': location,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'responses': 0,
      });

      print('✅ Bildirim başarıyla eklendi: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ NotificationService hatası: $e');
      print('❌ Hata türü: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Bekleyen bildirimleri getir (Admin için)
  static Stream<QuerySnapshot> getPendingNotifications() {
    return _firestore
        .collection('notifications')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Onaylanmış bildirimleri getir (Admin için)
  static Stream<QuerySnapshot> getApprovedNotifications() {
    return _firestore
        .collection('notifications')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true) // approvedAt yerine createdAt kullan
        .snapshots();
  }

  // Bildirimi onayla (Admin için)
  static Future<bool> approveNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Bildirim onaylama hatası: $e');
      return false;
    }
  }

  // Bildirimi reddet (Admin için)
  static Future<bool> rejectNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Bildirim reddetme hatası: $e');
      return false;
    }
  }

  // İstatistikler için toplam sayıları getir
  static Future<Map<String, int>> getStatistics() async {
    try {
      final pendingSnapshot = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'pending')
          .get();
      
      final approvedSnapshot = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'approved')
          .get();
      
      final rejectedSnapshot = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'rejected')
          .get();

      return {
        'pending': pendingSnapshot.docs.length,
        'approved': approvedSnapshot.docs.length,
        'rejected': rejectedSnapshot.docs.length,
        'total': pendingSnapshot.docs.length + approvedSnapshot.docs.length + rejectedSnapshot.docs.length,
      };
    } catch (e) {
      print('İstatistik alma hatası: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0, 'total': 0};
    }
  }

  // Kullanıcının bildirimlerini getir
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    print('🔍 NotificationService.getUserNotifications çağrıldı');
    print('👤 Aranan kullanıcı ID: $userId');
    
    try {
      final stream = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
      
      print('✅ Stream oluşturuldu');
      return stream;
    } catch (e) {
      print('❌ getUserNotifications hatası: $e');
      print('❌ Hata türü: ${e.runtimeType}');
      rethrow;
    }
  }

  // İstatistikler için
  static Future<Map<String, int>> getNotificationStats() async {
    try {
      final pending = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'pending')
          .get();
      
      final approved = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'approved')
          .get();
      
      final rejected = await _firestore
          .collection('notifications')
          .where('status', isEqualTo: 'rejected')
          .get();

      return {
        'pending': pending.docs.length,
        'approved': approved.docs.length,
        'rejected': rejected.docs.length,
        'total': pending.docs.length + approved.docs.length + rejected.docs.length,
      };
    } catch (e) {
      print('İstatistik alma hatası: $e');
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'total': 0,
      };
    }
  }
}