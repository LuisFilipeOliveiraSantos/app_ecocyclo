// lib/services/avaliacao_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class AvaliacaoService {
  // POST - Criar avaliação
  static Future<Map<String, dynamic>> criarAvaliacao({
    required String companyUuid,
    required String companyAvaliadoraUuid,
    required String discardUuid,
    required int score,
    required String comment,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'company_uuid': companyUuid,
        'company_avaliadora_uuid': companyAvaliadoraUuid,
        'discard_uuid': discardUuid,
        'score': score,
        'comment': comment,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao criar avaliação: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // GET - Buscar avaliação específica
  static Future<Map<String, dynamic>> getAvaliacao(String ratingUuid) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/$ratingUuid");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // PATCH - Atualizar avaliação
  static Future<Map<String, dynamic>> atualizarAvaliacao({
    required String ratingUuid,
    required int score,
    required String comment,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/$ratingUuid");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'score': score,
        'comment': comment,
      });

      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao atualizar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // GET - Resumo de avaliações da empresa
  static Future<Map<String, dynamic>> getResumoAvaliacoes(String companyUuid) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/company/$companyUuid/summary");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao buscar resumo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}