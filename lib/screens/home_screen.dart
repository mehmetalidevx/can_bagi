import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:can_bagi/main.dart'; // MyApp için
import 'package:can_bagi/screens/login_screen.dart'; // LoginScreen için
import 'package:can_bagi/screens/create_notification_screen.dart'; // CreateNotificationScreen için
import 'package:can_bagi/screens/settings_screen.dart'; // Import ekleyin
import 'package:can_bagi/screens/notifications_history_screen.dart'; // Import ekleyin
import 'package:can_bagi/screens/ai_chat_screen.dart'; // AI Chat Screen için
import 'package:can_bagi/services/auth_service.dart'; // AuthService import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Harita, 1: Acil İhtiyaç, 2: Bildirimler, 3: Profil
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  final Set<Marker> _markers = {};

  // Kullanıcı bilgileri
  String userName = 'Kullanıcı Adı';
  String userBloodType = 'A Rh+';
  Map<String, dynamic>? userData;

  // Kan grubu bilgileri map'i
  static const Map<String, Map<String, dynamic>> _bloodTypeInfo = {
    'A Rh+': {
      'percentage': '%34',
      'canReceiveFrom': ['A Rh+', 'A Rh-', 'O Rh+', 'O Rh-'],
      'canDonateTo': ['A Rh+', 'AB Rh+'],
    },
    'A Rh-': {
      'percentage': '%6',
      'canReceiveFrom': ['A Rh-', 'O Rh-'],
      'canDonateTo': ['A Rh+', 'A Rh-', 'AB Rh+', 'AB Rh-'],
    },
    'B Rh+': {
      'percentage': '%9',
      'canReceiveFrom': ['B Rh+', 'B Rh-', 'O Rh+', 'O Rh-'],
      'canDonateTo': ['B Rh+', 'AB Rh+'],
    },
    'B Rh-': {
      'percentage': '%2',
      'canReceiveFrom': ['B Rh-', 'O Rh-'],
      'canDonateTo': ['B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-'],
    },
    'AB Rh+': {
      'percentage': '%3',
      'canReceiveFrom': ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-'],
      'canDonateTo': ['AB Rh+'],
    },
    'AB Rh-': {
      'percentage': '%1',
      'canReceiveFrom': ['A Rh-', 'B Rh-', 'AB Rh-', 'O Rh-'],
      'canDonateTo': ['AB Rh+', 'AB Rh-'],
    },
    'O Rh+': {
      'percentage': '%38',
      'canReceiveFrom': ['O Rh+', 'O Rh-'],
      'canDonateTo': ['A Rh+', 'B Rh+', 'AB Rh+', 'O Rh+'],
    },
    'O Rh-': {
      'percentage': '%7',
      'canReceiveFrom': ['O Rh-'],
      'canDonateTo': ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-'],
    },
  };

  // Kullanıcının kan grubu bilgilerini almak için getter
  Map<String, dynamic>? get bloodInfo => _bloodTypeInfo[userBloodType];

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.9334, 32.8597), // Ankara koordinatları
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserData(); // Kullanıcı bilgilerini yükle
  }

  // Kullanıcı bilgilerini yükle
  Future<void> _loadUserData() async {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      final currentUser = await user;
      final data = await AuthService.getUserData(currentUser?.uid ?? '');
      if (data != null && mounted) {
        setState(() {
          userData = data;
          userName = data['fullName'] ?? 'Kullanıcı Adı';
          userBloodType = data['bloodType'] ?? 'A Rh+';
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Konumunuz'),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bildirimler sekmesinde AppBar'ı gizle
          if (_selectedIndex != 2 && _selectedIndex != 3) _buildAppBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Harita',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bloodtype_outlined),
                activeIcon: Icon(Icons.bloodtype),
                label: 'Acil İhtiyaç',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Bildirimler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy),
                label: 'AI Asistan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                if (_currentPosition != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Can Bağı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppTheme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // _buildAppBar metodunda tema değiştirme butonunun onPressed metodunu güncelleyin
                onPressed: () {
                  setState(() {
                    AppTheme.toggleTheme();
                  });
                  // MyApp'i yeniden oluşturmak için Navigator kullanıyoruz
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  // Bildirimler sayfasına git
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMapView();
      case 1:
        return _buildEmergencyView();
      case 2:
        return NotificationsHistoryScreen(notifications: _userNotifications);
      case 3:
        return const AIChatScreen();
      case 4:
        return _buildProfileView();
      default:
        return _buildMapView();
    }
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmergencyView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.bloodtype,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acil Kan İhtiyaç',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Acil kan ihtiyacı bildirimi oluşturun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Acil kan ihtiyacı bildirimi oluştur
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateNotificationScreen(
                              onTabChange: _changeTab,
                              onNotificationCreated: _addNotification,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Bildirim Oluştur',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // _buildProfileView metodunda menü listesine çıkış yap seçeneği ekleyin
  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName, // Gerçek kullanıcı adı
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userBloodType,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kan Grubu Bilgileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.pie_chart, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Bulunabilirlik Oranı:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(bloodInfo?['percentage'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kan Alabileceği Gruplar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (bloodInfo?['canReceiveFrom'] as List<String>? ?? [])
                        .map((type) => Chip(
                              avatar: const Icon(Icons.arrow_downward, size: 16, color: Colors.white),
                              label: Text(type),
                              backgroundColor: AppTheme.primaryColor,
                              labelStyle: const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kan Verebileceği Gruplar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (bloodInfo?['canDonateTo'] as List<String>? ?? [])
                        .map((type) => Chip(
                              avatar: const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                              label: Text(type),
                              backgroundColor: AppTheme.successColor,
                              labelStyle: const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildProfileListTile(
                  icon: Icons.settings,
                  title: 'Ayarlar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildProfileListTile(
                  icon: Icons.help_outline,
                  title: 'Yardım ve Destek',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildProfileListTile(
                  icon: Icons.info_outline,
                  title: 'Hakkında',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildProfileListTile(
                  icon: Icons.logout,
                  title: 'Çıkış Yap',
                  onTap: () {
                    _showLogoutConfirmation(); // Onay dialog'u göster
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.primaryColor,
      ),
      onTap: onTap,
    );
  }

  // Çıkış onay dialog'u
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                _logout(); // Çıkış yap
              },
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Çıkış işlemi
  void _logout() async {
    await AuthService.signOut(); // Firebase'den çıkış yap
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Bildirimler listesi için state ekle
  List<Map<String, dynamic>> _userNotifications = [];

  // Bildirim ekleme metodu
  void _addNotification(Map<String, dynamic> notification) {
    setState(() {
      _userNotifications.insert(0, notification); // En başa ekle
    });
  }

  // Sekme değiştirme metodu
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}