import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart'; // Mantenha seu import original
import '../models/disposal_point.dart';

class MapService {
  final String? token;

  MapService(this.token);

  Future<LatLng> getUserCompanyLocation() async {
    const fallback = LatLng(-8.0476, -34.8770); // Recife Zero Marco
    if (token == null) return fallback;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.companyMe),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Tenta pegar lat/long direto
        if (data['latitude'] != null && data['longitude'] != null) {
          return LatLng(
            double.parse(data['latitude'].toString()),
            double.parse(data['longitude'].toString())
          );
        }
        
        // Se não tiver lat/long, tenta geocoding pelo endereço
        final address = _buildAddressString(data);
        if (address.isNotEmpty) {
           final locations = await locationFromAddress(address);
           if (locations.isNotEmpty) {
             return LatLng(locations.first.latitude, locations.first.longitude);
           }
        }
      }
    } catch (e) {
      print('Erro ao buscar localização do usuário: $e');
    }
    return fallback;
  }

  Future<List<DisposalPoint>> fetchCompanies(LatLng userLocation) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.mapCollectors),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        var companies = data.map((item) => DisposalPoint.fromJson(item)).toList();
        
        // Calcular distâncias e ordenar
        return _calculateDistances(userLocation, companies);
      }
    } catch (e) {
      print('Erro API Mapas: $e');
    }
    return _getFallbackData(); // Retorna dados fake em caso de erro
  }

  List<DisposalPoint> _calculateDistances(LatLng userLoc, List<DisposalPoint> list) {
    for (var item in list) {
      if (item.location != null) {
        final meters = Geolocator.distanceBetween(
          userLoc.latitude, userLoc.longitude,
          item.location!.latitude, item.location!.longitude
        );
        item.distance = meters / 1000;
      }
    }
    list.sort((a, b) => (a.distance ?? 9999).compareTo(b.distance ?? 9999));
    return list;
  }

  String _buildAddressString(Map<String, dynamic> data) {
    return [data['rua'], data['numero'], data['cidade'], data['uf'],data['bairro'], data['cep']]
        .where((e) => e != null).join(', ');
  }

  List<DisposalPoint> _getFallbackData() {
    // Sua lista hardcoded original entra aqui...
    return [
      DisposalPoint(
        id: '1',
        name: 'RecyclaByte',
        company_description:
            'Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos.',
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
        company_description:
            'ONG que recebe doações de equipamentos eletrônicos.',
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