// lib/services/discard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart'; // Para pegar o token se precisar

class DiscardService {
  static Future<void> createDiscard({
    required String idSolicitante,
    required String idSolicitada,
    required Map<String, int> geminiItens,
    required DateTime dataDescarte,
    required String localColeta,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/");


    final Map<String, dynamic> body = {
      'empresa_solicitante_id': idSolicitante,
      'empresa_solicitada_id': idSolicitada,
      'gemini_itens': geminiItens,
      'data_descarte': dataDescarte.toIso8601String(),
      'local_coleta': localColeta,
    };

    print('📤 Enviando descarte para API: ${jsonEncode(body)}'); // DEBUG

    // Se precisar de autenticação, pegar o token
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print('📥 Resposta da API: ${response.statusCode}'); // DEBUG
    print('📥 Body da resposta: ${response.body}'); // DEBUG

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      final message = decoded['detail'] ?? decoded['message'] ?? 'Erro ao criar descarte';
      throw Exception(message);
    }

  }
}