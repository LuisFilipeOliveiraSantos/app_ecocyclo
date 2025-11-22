// lib/services/item_reference_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ItemReferenceService {
  static Future<Map<String, dynamic>> getAvailableItems() async {
    try {
      final token = await AuthService.getToken();
      
      // ✅ CORRIGIDO: caminho correto
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/api/v1/environmental-reports/info/itens");
      
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print('📡 Buscando itens do backend: $url');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Itens carregados do backend: ${data['total_itens_cadastrados']} itens');
        
        // DEBUG: Mostrar estrutura completa da resposta
        print('🔍 Estrutura da resposta:');
        print(' - Fonte: ${data['fonte']}');
        print(' - Itens disponíveis: ${data['itens_disponiveis']}');
        print(' - Valores referencia:');
        if (data['valores_referencia'] != null) {
          data['valores_referencia'].forEach((key, value) {
            print('   * $key: $value');
          });
        }
        
        return data;
      } else {
        print('❌ Erro ao buscar itens: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        throw Exception('Falha ao carregar itens: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição de itens: $e');
      throw Exception('Erro ao carregar dados dos itens: $e');
    }
  }

  // Método para mapear nomes do backend para ícones do Flutter
  static IconData getIconForItem(String itemName) {
    final iconMap = {
      'laptop': Icons.laptop,
      'celular': Icons.phone_iphone,
      'smartphone': Icons.phone_iphone,
      'tablet': Icons.tablet,
      'monitor': Icons.monitor,
      'teclado': Icons.keyboard,
      'mouse': Icons.mouse,
      'headset': Icons.headset,
      'cpu': Icons.computer,
      'placa_mae': Icons.memory,
      'controle_remoto': Icons.settings_remote,
    };

    return iconMap[itemName.toLowerCase()] ?? Icons.devices_other;
  }

  // Método para converter risco do backend para o formato do frontend
  static String convertRiskLevel(String backendRisk) {
    switch (backendRisk.toLowerCase()) {
      case 'alto':
        return 'Alto';
      case 'medio':
        return 'Médio';
      case 'baixo':
        return 'Baixo';
      default:
        return 'Médio';
    }
  }
}