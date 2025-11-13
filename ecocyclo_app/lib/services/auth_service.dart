// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Chaves para SharedPreferences
  static const String _tokenKey = 'access_token';
  static const String _companyNameKey = 'company_name';
  static const String _companyIdKey = 'company_id';
  static const String _companyEmailKey = 'company_email';

  // Função de login
  static Future<void> login(String email, String password) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/login/access-token");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'password',
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      // Salva informações da empresa após login
      await _saveCompanyInfo(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Falha ao realizar login. Verifique suas credenciais.');
    }
  }

  // Salvar informações da empresa
  static Future<void> _saveCompanyInfo(String token) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/me");
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString(_companyNameKey, data['nome'] ?? "Empresa");
        await prefs.setString(_companyIdKey, data['uuid'] ?? data['id']?.toString() ?? "");
        await prefs.setString(_companyEmailKey, data['email'] ?? "");
      }
    } catch (e) {
      print('Erro ao salvar info da empresa: $e');
    }
  }

  // Função para pegar token armazenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Buscar nome da empresa (com cache)
  static Future<String> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyNameKey) ?? "Empresa";
  }

  // Buscar UUID da empresa (com cache)
  static Future<String> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyIdKey) ?? "";
  }

  // Buscar email da empresa (com cache)
  static Future<String> getCompanyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyEmailKey) ?? "";
  }

  // Buscar dados completos da empresa
  static Future<Map<String, dynamic>?> getCompanyProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/me");

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Atualiza o cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_companyNameKey, data['nome'] ?? "Empresa");
        await prefs.setString(_companyIdKey, data['uuid'] ?? data['id']?.toString() ?? "");
        await prefs.setString(_companyEmailKey, data['email'] ?? "");
        
        return data;
      } else {
        throw Exception('Falha ao carregar perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Verificar se está logado
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ✅ MÉTODO ADICIONADO: Atualizar informações locais após edição do perfil
  static Future<void> updateLocalCompanyInfo(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyNameKey, name);
    await prefs.setString(_companyEmailKey, email);
  }

  // Função de registro (se necessário)
  static Future<void> register(Map<String, dynamic> companyData) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/register");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(companyData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Registro bem sucedido
      final data = jsonDecode(response.body);
      // Pode fazer login automático ou redirecionar para login
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Falha no registro');
    }
  }

  // Função de logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_companyNameKey);
    await prefs.remove(_companyIdKey);
    await prefs.remove(_companyEmailKey);
  }

  // Verificar token expirado
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/me");
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}