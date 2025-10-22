import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class RegisterService {
  static Future<void> register({
    required String email,
    required String password,
    required String name,
    required String cnpj,
    required String telefone,
    required String company_type,
    required String cep,
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String uf,
    String? complemento,
    String? referencia,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/register");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'confirm_password': password,
        'nome': name,
        'cnpj': cnpj,
        'telefone': telefone,
        'company_type': company_type,
        'cep': cep,
        'rua': rua,
        'numero': numero,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
        'complemento': complemento ?? '',
        'referencia': referencia ?? '',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? 'Erro no registro';
      throw Exception(message);
    }
  }
}
