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

  // Método para buscar um descarte específico pelo ID
  static Future<Map<String, dynamic>> getDiscardById(String discardId) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/$discardId");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map<String, dynamic> ? data : {};
      } else {
        throw Exception('Erro ao buscar descarte: ${response.statusCode}');
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

  static Future<void> confirmDiscard(String discardId) async {
    try {
      final token = await AuthService.getToken();
      
      // Primeiro busca os dados atuais do descarte
      final discardData = await getDiscardById(discardId);
      
      if (discardData.isEmpty) {
        throw Exception('Dados do descarte não encontrados');
      }

      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/update/$discardId");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Prepara o corpo com todos os campos necessários, atualizando apenas o status
      final body = jsonEncode({
        'empresa_solicitante_id': discardData['empresa_solicitante_id'],
        'empresa_solicitada_id': discardData['empresa_solicitada_id'],
        'gemini_itens': discardData['gemini_itens'] ?? {},
        'data_descarte': discardData['data_descarte'],
        'local_coleta': discardData['local_coleta'],
        'status': 'completo' // Apenas este campo é alterado
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception('Erro ao finalizar coleta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}