import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:can_bagi/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? notifications;
  
  const NotificationsHistoryScreen({
    super.key,
    this.notifications,
  });

  @override
  State<NotificationsHistoryScreen> createState() => _NotificationsHistoryScreenState();
}

class _NotificationsHistoryScreenState extends State<NotificationsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bildirimlerim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Gönderdiğiniz kan talepleriniz',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    print('🔍 NotificationsHistoryScreen - Kullanıcı kontrolü');
    print('👤 Mevcut kullanıcı: ${currentUser?.uid}');
    print('📧 Kullanıcı email: ${currentUser?.email}');
    
    if (currentUser == null) {
      print('❌ Kullanıcı giriş yapmamış');
      return _buildEmptyState('Lütfen önce giriş yapın');
    }

    print('🔄 NotificationService.getUserNotifications çağrılıyor...');
    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService.getUserNotifications(currentUser.uid),
      builder: (context, snapshot) {
        print('📊 StreamBuilder durumu: ${snapshot.connectionState}');
        print('📊 Hata var mı: ${snapshot.hasError}');
        print('📊 Veri var mı: ${snapshot.hasData}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Veriler yükleniyor...');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('❌ Bildirim yükleme hatası: ${snapshot.error}');
          print('❌ Hata detayı: ${snapshot.error.runtimeType}');
          print('❌ Stack trace: ${snapshot.stackTrace}');
          return _buildEmptyState('Bildirimler yüklenirken hata oluştu\nHata: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('📭 Bildirim bulunamadı');
          print('📊 Döküman sayısı: ${snapshot.data?.docs.length ?? 0}');
          return _buildEmptyState('Henüz bildirim göndermediniz');
        }

        print('✅ ${snapshot.data!.docs.length} bildirim bulundu');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final notification = doc.data() as Map<String, dynamic>;
            notification['id'] = doc.id;
            
            print('📋 Bildirim ${index + 1}: ${notification['bloodType']} - ${notification['status']}');
            return _buildNotificationCard(notification);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Acil kan ihtiyacı durumunda bildirim oluşturabilirsiniz',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final status = notification['status'] ?? 'pending';
    final createdAt = notification['createdAt'] as Timestamp?;
    final date = createdAt?.toDate() ?? DateTime.now();
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Onay Bekleniyor';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Onaylandı';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Reddedildi';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Bilinmeyen';
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notification['bloodType'] ?? 'Bilinmeyen',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notification['location'] ?? 'Konum belirtilmedi',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (notification['description'] != null && notification['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                notification['description'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getUrgencyColor(notification['urgency']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    notification['urgency'] ?? 'Normal',
                    style: TextStyle(
                      color: _getUrgencyColor(notification['urgency']),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${notification['responses'] ?? 0} yanıt',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency) {
      case 'Acil':
        return Colors.red;
      case 'Yüksek':
        return Colors.orange;
      case 'Normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}