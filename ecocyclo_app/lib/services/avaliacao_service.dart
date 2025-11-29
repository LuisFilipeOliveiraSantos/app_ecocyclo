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

      // 🔍 DEBUG: Verificar os UUIDs antes de enviar
      print('🔍 DEBUG AVALIAÇÃO SERVICE - CRIAR:');
      print('   companyUuid: $companyUuid');
      print('   companyAvaliadoraUuid: $companyAvaliadoraUuid');
      print('   discardUuid: $discardUuid');
      print('   score: $score');
      print('   comment: $comment');
      print('   token exists: ${token != null}');

      final body = json.encode({
        'company_uuid': companyUuid,
        'company_avaliadora_uuid': companyAvaliadoraUuid,
        'discard_uuid': discardUuid,
        'score': score,
        'comment': comment,
      });

      print('📤 Request body: $body');

      final response = await http.post(
        url, 
        headers: headers, 
        body: body,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // 🔍 DEBUG: Mostrar erro completo
        final errorBody = response.body;
        print('❌ ERROR RESPONSE: $errorBody');
        throw Exception('Erro ao criar avaliação: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ EXCEPTION CRIAR: $e');
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

  // PATCH - Atualizar avaliação (VERSÃO CORRIGIDA)
  static Future<Map<String, dynamic>> atualizarAvaliacao({
    required String ratingUuid,
    required int score,
    required String comment,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'score': score,
        'comment': comment,
      });

      print('🔄 DEBUG ATUALIZAR AVALIAÇÃO:');
      print('   ratingUuid: $ratingUuid');
      print('   score: $score');
      print('   comment: $comment');

      // 🔥 TENTATIVA CORRETA: Endpoint update com rating_uuid como query parameter
      try {
        final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/update?rating_uuid=$ratingUuid");
        print('   URL: $url');
        print('   Método: PATCH');
        print('   Query parameter: rating_uuid=$ratingUuid');
        print('   Body: $body');
        
        final response = await http.patch(url, headers: headers, body: body);
        print('   Response - Status: ${response.statusCode}');
        print('   Response - Body: ${response.body}');

        if (response.statusCode == 200) {
          print('✅ Atualização bem-sucedida!');
          return jsonDecode(response.body);
        } else {
          print('❌ Falhou - Status: ${response.statusCode}');
          throw Exception('Erro ao atualizar avaliação: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('❌ Tentativa falhou: $e');
        throw e;
      }

    } catch (e) {
      print('❌ EXCEPTION ATUALIZAR AVALIAÇÃO: $e');
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

  // ✅ MÉTODO: Verificar se já existe avaliação para este descarte
  static Future<bool> verificarAvaliacaoExistente(String discardUuid) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/my/avaliations");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('🔍 DEBUG VERIFICAR AVALIAÇÃO EXISTENTE:');
      print('   discardUuid: $discardUuid');
      print('   URL: $url');

      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final avaliacoes = jsonDecode(response.body) as List;
        
        print('🔍 Total de avaliações encontradas: ${avaliacoes.length}');
        
        // Verificar se existe alguma avaliação com o mesmo discard_uuid
        final avaliacaoExistente = avaliacoes.firstWhere(
          (avaliacao) => avaliacao['discard_uuid'] == discardUuid,
          orElse: () => null,
        );

        if (avaliacaoExistente != null) {
          print('✅ Avaliação existente encontrada: ${avaliacaoExistente['uuid']}');
        } else {
          print('❌ Nenhuma avaliação encontrada para este discard');
        }

        return avaliacaoExistente != null;
      } else {
        throw Exception('Erro ao buscar avaliações: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EXCEPTION VERIFICAR AVALIAÇÃO: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  // ✅ MÉTODO: Buscar avaliação existente pelo discard_uuid
  static Future<Map<String, dynamic>?> buscarAvaliacaoPorDiscard(String discardUuid) async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/my/avaliations");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('🔍 DEBUG BUSCAR AVALIAÇÃO EXISTENTE:');
      print('   discardUuid: $discardUuid');
      print('   URL: $url');

      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final avaliacoes = jsonDecode(response.body) as List;
        
        print('🔍 Total de avaliações encontradas: ${avaliacoes.length}');
        
        for (var i = 0; i < avaliacoes.length; i++) {
          final avaliacao = avaliacoes[i];
          print('   Avaliação $i: discard_uuid=${avaliacao['discard_uuid']}, uuid=${avaliacao['uuid']}');
        }
        
        final avaliacaoExistente = avaliacoes.firstWhere(
          (avaliacao) => avaliacao['discard_uuid'] == discardUuid,
          orElse: () => null,
        );

        if (avaliacaoExistente != null) {
          print('✅ Avaliação existente encontrada: ${avaliacaoExistente['uuid']}');
        } else {
          print('❌ Nenhuma avaliação encontrada para este discard');
        }

        return avaliacaoExistente;
      } else {
        throw Exception('Erro ao buscar avaliações: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ EXCEPTION BUSCAR AVALIAÇÃO: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  // ✅ MÉTODO ADICIONAL: Buscar todas as minhas avaliações (para debug)
  static Future<List<dynamic>> getMinhasAvaliacoes() async {
    try {
      final token = await AuthService.getToken();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/avaliations/my/avaliations");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List;
      } else {
        throw Exception('Erro ao buscar minhas avaliações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}