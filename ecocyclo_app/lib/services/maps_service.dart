import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/disposal_point.dart';
import '../services/auth_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../config/api_config.dart';


class ApiConstants {
  static const String baseUrl = ApiConfig.baseUrl;
  static const String companyMe = baseUrl + '/company/me';
  static const String mapCollectors = baseUrl + '/company/map/coletoras';
}

class ApiService {
  final String token;

  ApiService(this.token);

  Future<LatLng> getUserLocation() async {
    LatLng fallbackLocation = LatLng(-8.0476, -34.8770);

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.companyMe),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['latitude'] != null && data['longitude'] != null) {
          return LatLng(
            data['latitude'] is String
                ? double.parse(data['latitude'])
                : (data['latitude'] as num).toDouble(),
            data['longitude'] is String
                ? double.parse(data['longitude'])
                : (data['longitude'] as num).toDouble(),
          );
        } else {
          final address = _buildAddressFromCompanyData(data);
          if (address.isNotEmpty) {
            final location = await _getLatLngFromAddress(address);
            if (location != null) return location;
          }
        }
      }
    } catch (_) {}
    return fallbackLocation;
  }

  Future<List<DisposalPoint>> getCompanies() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.mapCollectors),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DisposalPoint.fromJson(item)).toList();
      }
    } catch (_) {}
    return _loadFallbackData();
  }

  String _buildAddressFromCompanyData(Map<String, dynamic> data) {
    final parts = <String>[];
    if (data['rua'] != null) parts.add(data['rua']);
    if (data['numero'] != null) parts.add(data['numero']);
    if (data['bairro'] != null) parts.add(data['bairro']);
    if (data['cidade'] != null) parts.add(data['cidade']);
    if (data['uf'] != null) parts.add(data['uf']);
    if (data['cep'] != null) parts.add(data['cep']);
    return parts.join(', ');
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        return LatLng(loc.latitude, loc.longitude);
      }
    } catch (_) {}
    return null;
  }

  List<DisposalPoint> _loadFallbackData() {
    return [
      DisposalPoint(
        id: '1',
        name: 'RecyclaByte',
        companyDescription: 'Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos.',
        location: LatLng(-8.0476, -34.8770),
        categories: ['Reciclagem'],
        address: 'Rua Aurora, 123 - Boa Vista',
        phone: '(81) 3333-4444',
        rating: 4.98,
        logoPath: 'assets/icons/reciclagem.svg',
      ),
      DisposalPoint(
        id: '2',
        name: 'Tech Solidário',
        companyDescription: 'ONG que recebe doações de equipamentos eletrônicos.',
        location: LatLng(-8.0556, -34.8810),
        categories: ['Doação'],
        address: 'Av. Conde da Boa Vista, 456',
        phone: '(81) 9999-8888',
        rating: 4.85,
        logoPath: 'assets/icons/doacao.svg',
      ),
    ];
  }
}
