// lib/services/company_service.dart (ATUALIZADO)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class CompanyService {
  static final Map<String, Map<String, dynamic>> _companyCache = {};

  static Future<Map<String, dynamic>> getCompanyData(String companyId) async {
    if (_companyCache.containsKey(companyId)) {
      return _companyCache[companyId]!;
    }

    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/id")
          .replace(queryParameters: {'company_id': companyId});
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final companyData = jsonDecode(response.body);
        
        // Salva no cache
        _companyCache[companyId] = companyData;
        
        return companyData;
      } else {
        throw Exception('Erro ao buscar empresa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dados da empresa: $e');
    }
  }

  static Future<String> getCompanyName(String companyId) async {
    try {
      final data = await getCompanyData(companyId);
      return data['nome']?.toString() ?? 'Empresa Coletora';
    } catch (e) {
      return 'Empresa Coletora';
    }
  }

  static Future<String?> getCompanyPhoto(String companyId) async {
    try {
      final data = await getCompanyData(companyId);
      return data['company_photo_url']?.toString();
    } catch (e) {
      return null;
    }
  }

  static void clearCache() {
    _companyCache.clear();
  }
}