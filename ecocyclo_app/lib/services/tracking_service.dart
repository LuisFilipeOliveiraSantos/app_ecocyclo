// lib/services/tracking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class TrackingService {
  static Future<List<dynamic>> getDiscardsByCompany() async {
    try {
      final uuid = await AuthService.getCompanyId();
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/company/$uuid");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Erro ao buscar descartes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  static Future<void> cancelDiscard(String discardId) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/$discardId/cancel");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.put(url, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Erro ao cancelar descarte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}