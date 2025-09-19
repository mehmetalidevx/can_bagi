import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';

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
  // Örnek bildirim verileri - artık parametre olarak gelecek
  List<Map<String, dynamic>> get _notifications => widget.notifications ?? [
    {
      'id': '1',
      'bloodType': 'A Rh+',
      'urgency': 'Kritik',
      'location': 'Ankara Şehir Hastanesi',
      'description': 'Acil ameliyat için A Rh+ kan grubuna ihtiyaç var',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Aktif',
      'responses': 5,
    },
    {
      'id': '2',
      'bloodType': 'O Rh-',
      'urgency': 'Yüksek',
      'location': 'Hacettepe Üniversitesi Hastanesi',
      'description': 'Trafik kazası sonucu acil kan ihtiyacı',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Tamamlandı',
      'responses': 12,
    },
    {
      'id': '3',
      'bloodType': 'B Rh+',
      'urgency': 'Orta',
      'location': 'Gazi Üniversitesi Hastanesi',
      'description': 'Kanser tedavisi için kan bağışı gerekli',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'Aktif',
      'responses': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
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
                  Icons.history,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gönderilen Bildirimler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Toplam ${_notifications.length} bildirim',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz bildirim göndermediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acil kan ihtiyacı bildirimi oluşturmak için\n"Acil İhtiyaç" sekmesini kullanın',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isActive = notification['status'] == 'Aktif';
    final urgencyColor = _getUrgencyColor(notification['urgency']);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Durum ve tarih
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryColor : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notification['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(notification['date']),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Kan grubu ve aciliyet
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    notification['bloodType'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: urgencyColor),
                    ),
                    child: Text(
                      notification['urgency'],
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Konum
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification['location'],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Açıklama
              Text(
                notification['description'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // Alt kısım - Yanıtlar ve işlemler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${notification['responses']} yanıt',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        color: AppTheme.primaryColor,
                        iconSize: 20,
                        onPressed: () => _shareNotification(notification),
                      ),
                      if (isActive)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: AppTheme.primaryColor,
                          iconSize: 20,
                          onPressed: () => _editNotification(notification),
                        ),
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.stop_circle_outlined : Icons.delete_outline,
                        ),
                        color: isActive ? Colors.orange : Colors.red,
                        iconSize: 20,
                        onPressed: () => isActive 
                            ? _stopNotification(notification)
                            : _deleteNotification(notification),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Kritik':
        return Colors.red;
      case 'Yüksek':
        return Colors.orange;
      case 'Orta':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inMinutes} dakika önce';
    }
  }

  void _shareNotification(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim paylaşılıyor...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _editNotification(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim düzenleme özelliği yakında eklenecek'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _stopNotification(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Durdur'),
        content: const Text('Bu bildirimi durdurmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notification['status'] = 'Durduruldu';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirim durduruldu'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: const Text('Durdur'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.remove(notification);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bildirim silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}