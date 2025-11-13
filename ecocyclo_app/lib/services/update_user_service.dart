import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';


class CompanyService {
  final String token;

  CompanyService({required this.token});

  Future<Map<String, dynamic>> getCompanyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/company/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      } else if (response.statusCode == 404) {
        throw Exception('Perfil não encontrado.');
      } else {
        throw Exception('Erro ao carregar perfil: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow; // Já é uma Exception com mensagem tratada
      }
      throw Exception('Erro de conexão: $e');
    }
  }

  
Future<Map<String, dynamic>> updateCompanyProfile(Map<String, dynamic> data) async {
  try {

    final cleanedData = Map<String, dynamic>.from(data);
    cleanedData.removeWhere((key, value) => value == null);
    
    print('🔄 Enviando PATCH para API: $cleanedData');

    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/v1/company/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(cleanedData),
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📡 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('✅ API retornou: $responseData');
      return responseData;
    } else if (response.statusCode == 400) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Dados inválidos';
      print('❌ Erro 400: $errorMessage');
      throw Exception(errorMessage);
    } else if (response.statusCode == 401) {
      print('❌ Erro 401: Sessão expirada');
      throw Exception('Sessão expirada. Faça login novamente.');
    } else if (response.statusCode == 422) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? 'Dados de validação inválidos';
      print('❌ Erro 422: $errorMessage');
      throw Exception(errorMessage);
    } else {
      print('❌ Erro ${response.statusCode}: ${response.body}');
      throw Exception('Não foi possível salvar as alterações. Tente novamente.');
    }
  } catch (e) {
    print('❌ Exception: $e');
    if (e is Exception) {
      rethrow;
    }
    throw Exception('Erro de conexão. Verifique sua internet e tente novamente.');
  }
}
}