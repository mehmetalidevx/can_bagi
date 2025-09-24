import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlacesService {
  static final String _apiKey = dotenv.env['AIzaSyC-1X7mhgLRMLn45NGhVO41xcdVp2-bBk0'] ?? '';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static Future<List<Map<String, dynamic>>> getNearbyHealthFacilities({
    required double lat,
    required double lng,
    required String type, // hospital, pharmacy, blood_bank
    int radius = 5000,
  }) async {
    print('🔍 Searching for $type near $lat, $lng with radius $radius');
    print('🔑 API Key: ${_apiKey.isNotEmpty ? "Available" : "Missing"}');
    
    String placeType;
    switch (type) {
      case 'hospital':
        placeType = 'hospital';
        break;
      case 'pharmacy':
        placeType = 'pharmacy';
        break;
      case 'blood_bank':
        placeType = 'hospital'; // Kan merkezleri genelde hastane kategorisinde
        break;
      default:
        placeType = 'hospital';
    }

    final String url = '$_baseUrl/nearbysearch/json?'
        'location=$lat,$lng&'
        'radius=$radius&'
        'type=$placeType&'
        'key=$_apiKey';

    print('🌐 API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // API hatası kontrolü
        if (data['status'] != 'OK') {
          print('❌ API Status Error: ${data['status']}');
          print('❌ Error Message: ${data['error_message'] ?? 'No error message'}');
          return [];
        }
        
        final List<dynamic> results = data['results'] ?? [];
        print('✅ Found ${results.length} places for $type');
        
        return results.map<Map<String, dynamic>>((place) {
          return {
            'name': place['name'] ?? 'Bilinmeyen',
            'type': type,
            'lat': place['geometry']['location']['lat'],
            'lng': place['geometry']['location']['lng'],
            'address': place['vicinity'] ?? 'Adres bilgisi yok',
            'rating': place['rating']?.toDouble() ?? 0.0,
            'place_id': place['place_id'] ?? '',
          };
        }).toList();
      } else {
        print('❌ Places API Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Places API Exception: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final String url = '$_baseUrl/details/json?'
        'place_id=$placeId&'
        'fields=name,formatted_address,formatted_phone_number,opening_hours,website&'
        'key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'];
      }
    } catch (e) {
      print('Place Details Exception: $e');
    }
    return null;
  }
}