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
        'grant_type': 'password', // importante para OAuth2
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      // Salva o token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      // Não retorna mensagem do backend
      return;
    } else {
      // Exibe apenas uma mensagem genérica
      throw Exception('Falha ao realizar login. Verifique suas credenciais.');
    }
  }

  // Função para pegar token armazenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Função de logout (remove token)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
