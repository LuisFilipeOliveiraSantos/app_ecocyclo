import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
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
      await prefs.setString('access_token', token);
    } else {
      throw Exception('Falha ao realizar login. Verifique suas credenciais.');
    }
  }

  // Função para pegar token armazenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Buscar informações da empresa logada
  static Future<String> getCompanyName() async {
    final token = await getToken();
    if (token == null) return "Empresa";

    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/me");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['nome'] ?? "Empresa";
    } else {
      return "Empresa";
    }
  }

  // Função de logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
