import 'package:flutter/material.dart';
import 'package:can_bagi/theme/app_theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CreateNotificationScreen extends StatefulWidget {
  final Function(int)? onTabChange; // Sekme değiştirme callback'i
  final Function(Map<String, dynamic>)? onNotificationCreated; // Bildirim ekleme callback'i
  
  const CreateNotificationScreen({
    super.key,
    this.onTabChange,
    this.onNotificationCreated,
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker();
      });
      
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation,
            zoom: 14.0,
          ),
        ),
      );
    } catch (e) {
      print('Konum alınamadı: $e');
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: const InfoWindow(title: 'Seçilen Konum'),
        ),
      };
    });
  }

  Future<void> _createNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Burada bildirim oluşturma işlemi yapılacak
      // Normalde Firebase veya başka bir backend servisi kullanılır
      await Future.delayed(const Duration(seconds: 1));

      // Yeni bildirim verisi oluştur
      final newNotification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'bloodType': _selectedBloodType,
        'urgency': _selectedUrgency,
        'location': _locationController.text.isNotEmpty 
            ? _locationController.text 
            : 'Konum belirtilmedi',
        'description': _descriptionController.text,
        'date': DateTime.now(),
        'status': 'Aktif',
        'responses': 0,
      };

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Bildirimi listeye ekle
        if (widget.onNotificationCreated != null) {
          widget.onNotificationCreated!(newNotification);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim başarıyla oluşturuldu ve gönderildi!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        
        // Ana sayfaya dön ve bildirimler sekmesine geç
        Navigator.of(context).pop();
        
        // Bildirimler sekmesine geç
        if (widget.onTabChange != null) {
          widget.onTabChange!(2); // 2 = bildirimler sekmesi
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor, // Kırmızı arka plan eklendi
        title: const Text(
          'Acil Kan İhtiyacı Bildirimi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // İkonları beyaz yap
        actions: [
          IconButton(
            icon: Icon(
              _showPreview ? Icons.edit : Icons.preview,
              color: Colors.white, // İkon rengini beyaz yap
            ),
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
              });
            },
            tooltip: _showPreview ? 'Düzenle' : 'Önizle',
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
            // Bilgi metni
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lütfen acil kan ihtiyacı bildiriminizi oluşturun. '
                      'Bu bildirim yakındaki kan bağışçılarına iletilecektir.',
                      style: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Kan grubu seçimi
            const Text(
              'Kan Grubu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildBloodTypeSelector(),
            const SizedBox(height: 16),
            
            // Aciliyet seviyesi
            const Text(
              'Aciliyet Seviyesi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildUrgencySelector(),
            const SizedBox(height: 16),
            
            // Konum bilgisi
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
              decoration: const InputDecoration(
                hintText: 'Hastane adı veya adres',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen konum bilgisi girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Harita
            const Text(
              'Haritada Konum Seçin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14.0,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng latLng) {
                    setState(() {
                      _selectedLocation = latLng;
                      _updateMarker();
                    });
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
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'İhtiyaç hakkında detaylı bilgi',
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: AppTheme.primaryColor,
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen açıklama girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
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

  Widget _buildBloodTypeSelector() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _bloodTypes.length,
        itemBuilder: (context, index) {
          final bloodType = _bloodTypes[index];
          final isSelected = bloodType == _selectedBloodType;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBloodType = bloodType;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bloodType,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Row(
      children: _urgencyColors.entries.map((entry) {
        final urgency = entry.key;
        final color = entry.value;
        final isSelected = urgency == _selectedUrgency;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedUrgency = urgency;
              });
            },
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  urgency,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Önizleme başlığı
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Bildirim Önizleme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Bildirim kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst bilgi
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _urgencyColors[_selectedUrgency],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _selectedUrgency,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Şimdi',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Kan grubu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İhtiyaç Duyulan Kan Grubu',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedBloodType,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Konum
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Konum',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _locationController.text.isEmpty
                                ? 'Konum belirtilmedi'
                                : _locationController.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _selectedLocation,
                                  zoom: 14.0,
                                ),
                                markers: _markers,
                                liteModeEnabled: true,
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                                myLocationButtonEnabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Açıklama
                if (_descriptionController.text.isNotEmpty) ...[  
                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descriptionController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
                
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
        ],
      ),
    );
  }
}