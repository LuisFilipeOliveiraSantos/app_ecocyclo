// lib/services/environmental_report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class EnvironmentalReportService {
  // Criar ou atualizar relatório ambiental
  static Future<Map<String, dynamic>> createOrUpdateReport(String companyId, Map<String, int> itensProcessados) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      // Primeiro, verificar se já existe um relatório para esta empresa
      final existingReports = await getCompanyReports(companyId);
      
      if (existingReports.isNotEmpty) {
        // Se existe, atualizar o primeiro relatório encontrado
        final reportId = existingReports.first['report_id'];
        print('📝 Atualizando relatório existente: $reportId');
        return await updateReport(reportId, itensProcessados);
      } else {
        // Se não existe, criar novo relatório
        print('📝 Criando novo relatório para empresa: $companyId');
        return await createReport(companyId, itensProcessados);
      }
    } catch (e) {
      print('❌ Erro ao criar/atualizar relatório: $e');
      throw Exception('Erro ao processar relatório: $e');
    }
  }

  // Buscar relatórios da empresa
  static Future<List<dynamic>> getCompanyReports(String companyId) async {
    try {
      final token = await AuthService.getToken();
      // ✅ CORRIGIDO: endpoint correto para listar relatórios
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/api/v1/environmental-reports/listar-relatorios?empresa_id=$companyId");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('📡 Buscando relatórios da empresa: $url');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Relatórios encontrados: ${data.length}');
        return data;
      } else if (response.statusCode == 404) {
        // Se não encontrou relatórios, retorna lista vazia
        print('ℹ️  Nenhum relatório encontrado para a empresa');
        return [];
      } else {
        print('❌ Erro ao buscar relatórios: ${response.statusCode}');
        throw Exception('Falha ao buscar relatórios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição de relatórios: $e');
      throw Exception('Erro ao buscar relatórios: $e');
    }
  }

  // Criar novo relatório
  static Future<Map<String, dynamic>> createReport(String companyId, Map<String, int> itensProcessados) async {
    try {
      final token = await AuthService.getToken();
      // ✅ CORRIGIDO: endpoint correto para criar relatório
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/api/v1/environmental-reports/criar-relatorio");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Definir período (últimos 30 dias)
      final now = DateTime.now();
      final periodoInicio = now.subtract(Duration(days: 30));
      
      final body = {
        'empresa_id': companyId,
        'periodo_inicio': periodoInicio.toIso8601String(),
        'periodo_fim': now.toIso8601String(),
        'itens_processados': itensProcessados,
      };

      print('📡 Criando relatório: $url');
      print('📦 Dados: $body');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Relatório criado: ${data['report_id']}');
        return data;
      } else {
        print('❌ Erro ao criar relatório: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Falha ao criar relatório: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na criação de relatório: $e');
      throw Exception('Erro ao criar relatório: $e');
    }
  }

  // Atualizar relatório existente
  static Future<Map<String, dynamic>> updateReport(String reportId, Map<String, int> itensProcessados) async {
    try {
      final token = await AuthService.getToken();
      // ✅ CORRIGIDO: endpoint correto para atualizar relatório
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/api/v1/environmental-reports/$reportId/editar");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final body = {
        'itens_processados': itensProcessados,
      };

      print('📡 Atualizando relatório: $url');
      print('📦 Dados: $body');
      
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Relatório atualizado: $reportId');
        return data;
      } else {
        print('❌ Erro ao atualizar relatório: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Falha ao atualizar relatório: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na atualização de relatório: $e');
      throw Exception('Erro ao atualizar relatório: $e');
    }
  }

  // ✅ NOVO MÉTODO: Buscar relatório específico (se necessário)
  static Future<Map<String, dynamic>> getReportById(String reportId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/api/v1/environmental-reports/$reportId/relatorio");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('📡 Buscando relatório específico: $url');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Relatório encontrado: $reportId');
        return data;
      } else {
        print('❌ Erro ao buscar relatório: ${response.statusCode}');
        throw Exception('Falha ao buscar relatório: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na busca de relatório: $e');
      throw Exception('Erro ao buscar relatório: $e');
    }
  }
}