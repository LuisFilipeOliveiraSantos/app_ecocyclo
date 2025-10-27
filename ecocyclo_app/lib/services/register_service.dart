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
    String? company_description,
    List<String>? company_colector_tags,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/register");

    // Cria o body base
    final Map<String, dynamic> body = {
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
      'company_description': company_description ?? '',
    };

    // Adiciona tags apenas se for empresa coletora e houver tags
    if (company_type == 'coletora' && company_colector_tags != null && company_colector_tags.isNotEmpty) {
      body['company_colector_tags'] = company_colector_tags;
    }

    print('📤 Enviando para API: ${jsonEncode(body)}'); // DEBUG

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('📥 Resposta da API: ${response.statusCode}'); // DEBUG
    print('📥 Body da resposta: ${response.body}'); // DEBUG

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? 'Erro no registro';
      final details = decoded['details'] ?? decoded['error'] ?? '';
      throw Exception('$message $details');
    }
  }
}