import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:can_bagi/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Bu satırı ekleyin

class CreateNotificationScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  
  const CreateNotificationScreen({
    super.key,
    this.onTabChange,
  });

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedBloodType = 'A Rh+';
  String _selectedUrgency = 'Acil';
  bool _isLoading = false;
  bool _showPreview = false;
  
  // Harita için değişkenler
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(41.0082, 28.9784); // İstanbul varsayılan
  Set<Marker> _markers = {};
  Position? _currentPosition;

  final List<String> _bloodTypes = [
    'A Rh+', 'A Rh-', 'B Rh+', 'B Rh-',
    'AB Rh+', 'AB Rh-', 'O Rh+', 'O Rh-',
  ];

  final Map<String, Color> _urgencyColors = {
    'Acil': Colors.red,
    'Yüksek': Colors.orange,
    'Normal': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: _selectedLocation,
            infoWindow: const InfoWindow(title: 'Mevcut Konum'),
          ),
        };
      });

      // Konum adresini otomatik yazmıyoruz artık
      // _updateLocationText(); // Bu satırı kaldırıyoruz
    } catch (e) {
      print('Konum alma hatası: $e');
    }
  }

  Future<void> _updateLocationText() async {
    // Bu metodu artık kullanmıyoruz, sadece harita güncellemesi için
    // Konum alanını otomatik doldurmuyoruz
    // setState(() {
    //   _locationController.text = 'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, '
    //       'Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}';
    // });
  }

  Future<void> _createNotification() async {
    print('🔄 _createNotification başladı');
    
    if (_formKey.currentState!.validate()) {
      print('✅ Form validasyonu geçti');
      setState(() {
        _isLoading = true;
      });

      try {
        // Kullanıcı giriş kontrolü
        final currentUser = FirebaseAuth.instance.currentUser;
        print('👤 Mevcut kullanıcı: ${currentUser?.uid}');
        print('📧 Kullanıcı email: ${currentUser?.email}');
        
        if (currentUser == null) {
          print('❌ Kullanıcı giriş yapmamış!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lütfen önce giriş yapın!'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        print('📝 Bildirim parametreleri:');
        print('  - Kan grubu: $_selectedBloodType');
        print('  - Aciliyet: $_selectedUrgency');
        print('  - Konum: ${_locationController.text}');
        print('  - Açıklama: ${_descriptionController.text}');
        print('  - Koordinatlar: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');

        // Firebase'e bildirim kaydet
        print('🔄 NotificationService.createNotification çağrılıyor...');
        final notificationId = await NotificationService.createNotification(
          bloodType: _selectedBloodType,
          urgency: _selectedUrgency,
          location: _locationController.text.isNotEmpty 
              ? _locationController.text 
              : 'Konum belirtilmedi',
          description: _descriptionController.text,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );

        print('📋 Dönen notification ID: $notificationId');

        if (notificationId != null) {
          // Başarılı
          print('✅ Bildirim başarıyla oluşturuldu: $notificationId');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bildirim başarıyla oluşturuldu! Onay bekleniyor...'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            
            // Ana sayfaya dön ve bildirimler sekmesine geç
            Navigator.of(context).pop();
            
            if (widget.onTabChange != null) {
              widget.onTabChange!(2); // 2 = bildirimler sekmesi
            }
            
            // Bu satırı kaldırın çünkü artık gerekli değil:
            // if (widget.onNotificationCreated != null) {
            //   widget.onNotificationCreated!({...});
            // }
          }
        } else {
          // Hata
          print('❌ NotificationService null döndü');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bildirim oluşturulamadı. Kullanıcı girişi kontrol edin.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('❌ Bildirim oluşturma hatası: $e');
        print('❌ Hata türü: ${e.runtimeType}');
        print('❌ Stack trace: ${StackTrace.current}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print('❌ Form validasyonu başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Bildirim Oluştur'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
              });
            },
            child: Text(
              _showPreview ? 'Düzenle' : 'Önizle',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _showPreview ? _buildPreview() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kan grubu seçimi
            const Text(
              'Kan Grubu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBloodType,
                  isExpanded: true,
                  items: _bloodTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedBloodType = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Aciliyet durumu
            const Text(
              'Aciliyet Durumu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _urgencyColors.keys.map((String urgency) {
                final isSelected = _selectedUrgency == urgency;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUrgency = urgency;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _urgencyColors[urgency] 
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _urgencyColors[urgency]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          urgency,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _urgencyColors[urgency],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Konum
            const Text(
              'Konum',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Konum bilgisi',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konum bilgisi gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Harita
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedLocation = position;
                      _markers = {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: position,
                          infoWindow: const InfoWindow(title: 'Seçilen Konum'),
                        ),
                      };
                    });
                    // _updateLocationText(); // Bu satırı kaldırıyoruz
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Açıklama
            const Text(
              'Açıklama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Kan bağışı ihtiyacınızla ilgili detayları yazın...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Açıklama gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Gönder butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createNotification,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isLoading ? 'Gönderiliyor...' : 'Bildirimi Gönder',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                          color: _urgencyColors[_selectedUrgency]?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _urgencyColors[_selectedUrgency]!),
                        ),
                        child: Text(
                          _selectedUrgency,
                          style: TextStyle(
                            color: _urgencyColors[_selectedUrgency],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Şimdi',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.bloodtype, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Kan Grubu: $_selectedBloodType',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationController.text.isNotEmpty 
                              ? _locationController.text 
                              : 'Konum belirtilmedi',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_descriptionController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Açıklama',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _descriptionController.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Harita önizleme
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 15,
                ),
                markers: _markers,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gönder butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _createNotification,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isLoading ? 'Gönderiliyor...' : 'Bildirimi Gönder',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}