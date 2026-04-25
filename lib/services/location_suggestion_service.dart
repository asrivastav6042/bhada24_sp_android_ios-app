import 'package:dio/dio.dart';

class LocationSuggestion {
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });
}

class LocationSuggestionService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<LocationSuggestion>> searchAddress(String query) async {
    if (query.trim().length < 3) return [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
      'countrycodes': 'in',
    });

    final response = await _dio.getUri(
      uri,
      options: Options(
        headers: const {
          'User-Agent': 'bhada24-sp-app/1.0 (support@bhada24.com)',
        },
      ),
    );

    final data = response.data;
    if (data is! List) return [];

    return data.whereType<Map>().map((item) {
      final addressMap = (item['address'] is Map) ? item['address'] as Map : {};
      final city = (addressMap['city'] ??
              addressMap['town'] ??
              addressMap['village'] ??
              addressMap['municipality'] ??
              '')
          .toString();
      final state = (addressMap['state'] ?? '').toString();
      final pincode = (addressMap['postcode'] ?? '').toString();
      final displayName = (item['display_name'] ?? '').toString();
      final lat = double.tryParse((item['lat'] ?? '').toString()) ?? 0;
      final lon = double.tryParse((item['lon'] ?? '').toString()) ?? 0;

      return LocationSuggestion(
        address: displayName,
        city: city,
        state: state,
        pincode: pincode,
        latitude: lat,
        longitude: lon,
      );
    }).toList();
  }
}
