import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:can_bagi/services/notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, int> _statistics = {'pending': 0, 'approved': 0, 'rejected': 0, 'total': 0};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await NotificationService.getStatistics();
    setState(() {
      _statistics = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Admin Paneli',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sol menü
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                // İstatistikler
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İstatistikler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard('Bekleyen', _statistics['pending']!, Colors.orange),
                      const SizedBox(height: 8),
                      _buildStatCard('Onaylanan', _statistics['approved']!, Colors.green),
                      const SizedBox(height: 8),
                      _buildStatCard('Reddedilen', _statistics['rejected']!, Colors.red),
                      const SizedBox(height: 8),
                      _buildStatCard('Toplam', _statistics['total']!, Colors.blue),
                    ],
                  ),
                ),
                const Divider(),
                // Menü öğeleri
                ListTile(
                  leading: Icon(
                    Icons.pending_actions,
                    color: _selectedIndex == 0 ? AppTheme.primaryColor : Colors.grey,
                  ),
                  title: Text(
                    'Bekleyen Talepler',
                    style: TextStyle(
                      color: _selectedIndex == 0 ? AppTheme.primaryColor : Colors.black,
                      fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: _selectedIndex == 1 ? AppTheme.primaryColor : Colors.grey,
                  ),
                  title: Text(
                    'Onaylanan Talepler',
                    style: TextStyle(
                      color: _selectedIndex == 1 ? AppTheme.primaryColor : Colors.black,
                      fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          // Ana içerik
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedIndex == 0 ? 'Bekleyen Talepler' : 'Onaylanan Talepler',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _selectedIndex == 0 
                        ? _buildPendingNotifications()
                        : _buildApprovedNotifications(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService.getPendingNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Bekleyen talep bulunmuyor',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final notification = doc.data() as Map<String, dynamic>;
            notification['id'] = doc.id;
            
            return _buildNotificationCard(notification, isPending: true);
          },
        );
      },
    );
  }

  Widget _buildApprovedNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService.getApprovedNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Onaylanmış talep bulunmuyor',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final notification = doc.data() as Map<String, dynamic>;
            notification['id'] = doc.id;
            
            return _buildNotificationCard(notification, isPending: false);
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, {required bool isPending}) {
    final createdAt = notification['createdAt'] as Timestamp?;
    final approvedAt = notification['approvedAt'] as Timestamp?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['userName'] ?? 'Bilinmeyen Kullanıcı',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification['bloodType'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(notification['urgency'] ?? ''),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification['urgency'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (createdAt != null)
                  Text(
                    _formatDate(createdAt.toDate()),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    notification['location'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification['description'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _rejectNotification(notification['id']),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Reddet',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approveNotification(notification['id']),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Onayla',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ] else if (approvedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Onaylandı: ${_formatDate(approvedAt.toDate())}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
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
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  Future<void> _approveNotification(String notificationId) async {
    final success = await NotificationService.approveNotification(notificationId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirim başarıyla onaylandı!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadStatistics(); // İstatistikleri güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirim onaylanırken hata oluştu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectNotification(String notificationId) async {
    final success = await NotificationService.rejectNotification(notificationId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirim başarıyla reddedildi!'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadStatistics(); // İstatistikleri güncelle
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildirim reddedilirken hata oluştu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}