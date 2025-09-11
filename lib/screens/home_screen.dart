import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  final Set<Marker> _markers = {};

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.9334, 32.8597), // Ankara koordinatları
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisi açık mı kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Konum izni kontrol et
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

    // Konumu al
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        
        // Kullanıcının konumunu haritada işaretle
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Konumunuz'),
          ),
        );
      });

      // Haritayı kullanıcının konumuna taşı
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
          _buildAppBar(),
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
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMapView();
      case 1:
        return _buildEmergencyView();
      case 2:
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
            'Acil Kan İhtiyacı',
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
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Bildirim Oluştur', style: TextStyle(fontSize: 16)),
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
                  const Text(
                    'Kullanıcı Adı',
                    style: TextStyle(
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'A Rh+',
                          style: TextStyle(
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
            child: Column(
              children: [
                _buildProfileListTile(
                  icon: Icons.history,
                  title: 'Bağış Geçmişim',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildProfileListTile(
                  icon: Icons.settings_outlined,
                  title: 'Ayarlar',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _buildProfileListTile(
                  icon: Icons.info_outline,
                  title: 'Hakkında',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                // Çıkış yap
              },
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap', style: TextStyle(fontSize: 16)),
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
}