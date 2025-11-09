// lib/services/discard_report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class DiscardReportService {
  static Future<List<dynamic>> getCompanyDiscards(String companyId) async {
    print('🔍 Buscando TODOS os descartes da empresa: $companyId');
    
    // AGORA USA UUID DIRETAMENTE (backend corrigido)
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/company/$companyId");
    
    final token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('📡 URL da requisição: $url');
    
    try {
      final response = await http.get(url, headers: headers);
      print('📥 Resposta da API: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Encontrados ${data.length} descartes reais!');
        
        // DEBUG: Mostrar resumo dos descartes
        if (data.isNotEmpty) {
          int totalItens = 0;
          for (var discard in data) {
            final itens = discard['itens_descarte'] as Map<String, dynamic>? ?? {};
            itens.forEach((key, value) {
              final quantidade = _parseQuantidade(value);
              totalItens += quantidade;
            });
          }
          print('📊 Total de itens em todos os descartes: $totalItens');
        }
        
        return data;
      } else {
        print('❌ Erro ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Erro na requisição: $e');
      return [];
    }
  }

  // MÉTODO AUXILIAR: Converter qualquer valor para int seguro
  static int _parseQuantidade(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is Map<String, dynamic>) {
      final quant = value['quantidade'];
      return _parseQuantidade(quant);
    }
    return 0;
  }

  // Método para processar os dados do backend para o formato da tela
  static List<Map<String, dynamic>> processDiscardsData(List<dynamic> discards) {
    List<Map<String, dynamic>> processedItems = [];
    
    for (var discard in discards) {
      final itensDescarte = discard['itens_descarte'] as Map<String, dynamic>? ?? {};
      
      itensDescarte.forEach((itemName, itemData) {
        // USAR MÉTODO AUXILIAR para garantir que é int
        final quantidade = _parseQuantidade(itemData);
        
        final itemInfo = _getItemInfo(itemName, quantidade);
        processedItems.add({
          'type': itemInfo['name'],
          'quantity': quantidade,
          'recyclingRate': itemInfo['recyclingRate'],
          'price': itemInfo['price'],
          'risk': itemInfo['risk'],
          'riskLevel': itemInfo['riskLevel'],
          'observations': itemInfo['observations'],
          'discardDate': discard['data_descarte'],
          'icon': itemInfo['icon'],
          'priceRange': itemInfo['priceRange'],
        });
      });
    }
    
    print('🔄 Itens processados: ${processedItems.length}');
    return processedItems;
  }

  // Dados reais baseados na tabela fornecida
  static Map<String, dynamic> _getItemInfo(String rawName, int quantity) {
    final itemMap = {
      'laptop': {
        'name': 'Laptop',
        'recyclingRate': 85.0,
        'minPrice': 25.0,
        'maxPrice': 40.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Contém cobre, alumínio e pequenas quantidades de metais nobres.',
        'icon': Icons.laptop,
      },
      'notebook': {
        'name': 'Laptop',
        'recyclingRate': 85.0,
        'minPrice': 25.0,
        'maxPrice': 40.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Contém cobre, alumínio e pequenas quantidades de metais nobres.',
        'icon': Icons.laptop,
      },
      'celular': {
        'name': 'Celular',
        'recyclingRate': 82.5,
        'minPrice': 10.0,
        'maxPrice': 25.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Baterias e placas têm alto valor de metais preciosos.',
        'icon': Icons.phone_iphone,
      },
      'smartphone': {
        'name': 'Celular',
        'recyclingRate': 82.5,
        'minPrice': 10.0,
        'maxPrice': 25.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Baterias e placas têm alto valor de metais preciosos.',
        'icon': Icons.phone_iphone,
      },
      'tablet': {
        'name': 'Tablet',
        'recyclingRate': 80.0,
        'minPrice': 15.0,
        'maxPrice': 30.0,
        'risk': 'Médio',
        'riskLevel': 2,
        'observations': 'Similar ao celular, mas com menor densidade de metais.',
        'icon': Icons.tablet,
      },
      'monitor': {
        'name': 'Monitor',
        'recyclingRate': 77.5,
        'minPrice': 10.0,
        'maxPrice': 20.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Vidro e metais podem ser reaproveitados.',
        'icon': Icons.monitor,
      },
      'teclado': {
        'name': 'Teclado',
        'recyclingRate': 85.0,
        'minPrice': 1.0,
        'maxPrice': 3.0,
        'risk': 'Baixo',
        'riskLevel': 1,
        'observations': 'Valor pequeno, composto majoritariamente por plástico.',
        'icon': Icons.keyboard,
      },
      'mouse': {
        'name': 'Mouse',
        'recyclingRate': 80.0,
        'minPrice': 1.0,
        'maxPrice': 2.0,
        'risk': 'Baixo',
        'riskLevel': 1,
        'observations': 'Pouco material metálico recuperável.',
        'icon': Icons.mouse,
      },
      'headset': {
        'name': 'Headset',
        'recyclingRate': 75.0,
        'minPrice': 1.0,
        'maxPrice': 3.0,
        'risk': 'Baixo',
        'riskLevel': 1,
        'observations': 'Plástico e cobre; valor baixo.',
        'icon': Icons.headset,
      },
      'cpu': {
        'name': 'CPU',
        'recyclingRate': 90.0,
        'minPrice': 40.0,
        'maxPrice': 70.0,
        'risk': 'Médio',
        'riskLevel': 2,
        'observations': 'Metais estruturais (aço, alumínio) e placas de alto valor.',
        'icon': Icons.computer,
      },
      'gabinete': {
        'name': 'CPU',
        'recyclingRate': 90.0,
        'minPrice': 40.0,
        'maxPrice': 70.0,
        'risk': 'Médio',
        'riskLevel': 2,
        'observations': 'Metais estruturais (aço, alumínio) e placas de alto valor.',
        'icon': Icons.computer,
      },
      'placa_mae': {
        'name': 'Placa-mãe',
        'recyclingRate': 92.5,
        'minPrice': 50.0,
        'maxPrice': 120.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Contém ouro, prata, cobre e estanho — item mais valioso por peso.',
        'icon': Icons.memory,
      },
      'motherboard': {
        'name': 'Placa-mãe',
        'recyclingRate': 92.5,
        'minPrice': 50.0,
        'maxPrice': 120.0,
        'risk': 'Alto',
        'riskLevel': 3,
        'observations': 'Contém ouro, prata, cobre e estanho — item mais valioso por peso.',
        'icon': Icons.memory,
      },
      'controle_remoto': {
        'name': 'Controle Remoto',
        'recyclingRate': 75.0,
        'minPrice': 2.0,
        'maxPrice': 4.0,
        'risk': 'Baixo',
        'riskLevel': 1,
        'observations': 'Pouco metal, alto teor de plástico.',
        'icon': Icons.alarm,
      },
    };

    // Encontrar o item mais próximo
    final normalizedName = rawName.toLowerCase().trim();
    var itemKey = normalizedName;
    
    // Mapear sinônimos
    final synonyms = {
      'notebook': 'laptop',
      'smartphone': 'celular',
      'phone': 'celular',
      'gabinete': 'cpu',
      'motherboard': 'placa_mae',
      'placa mãe': 'placa_mae',
      'remote': 'controle_remoto',
      'controle': 'controle_remoto',
    };

    if (synonyms.containsKey(normalizedName)) {
      itemKey = synonyms[normalizedName]!;
    } else if (!itemMap.containsKey(normalizedName)) {
      // Tentar encontrar por substring
      for (final key in itemMap.keys) {
        if (normalizedName.contains(key) || key.contains(normalizedName)) {
          itemKey = key;
          break;
        }
      }
    }

    final itemData = itemMap[itemKey] ?? {
      'name': rawName,
      'recyclingRate': 75.0,
      'minPrice': 5.0,
      'maxPrice': 15.0,
      'risk': 'Médio',
      'riskLevel': 2,
      'observations': 'Item eletrônico genérico para descarte.',
      'icon': Icons.devices_other,
    };

    // CORREÇÃO: Adicionar null checks e garantir que os preços são doubles
    final minPrice = (itemData['minPrice'] as double?) ?? 5.0;
    final maxPrice = (itemData['maxPrice'] as double?) ?? 15.0;
    
    // Calcular preço baseado na quantidade (usando preço médio)
    final averagePrice = (minPrice + maxPrice) / 2;
    final totalPrice = averagePrice * quantity;

    return {
      'name': itemData['name'] as String,
      'recyclingRate': (itemData['recyclingRate'] as double?) ?? 75.0,
      'price': totalPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'risk': itemData['risk'] as String,
      'riskLevel': (itemData['riskLevel'] as int?) ?? 2,
      'observations': itemData['observations'] as String,
      'icon': itemData['icon'] as IconData,
      'priceRange': 'R\$$minPrice - R\$$maxPrice',
    };
  }

  // Método para gerar dados do gráfico do último semestre
  static Map<String, int> getLastSixMonthsData(List<dynamic> discards) {
    final now = DateTime.now();
    final Map<String, int> monthlyData = {};
    
    // Inicializar últimos 6 meses com zero
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.month}/${month.year}';
      monthlyData[monthKey] = 0;
    }
    
    // Contar descartes por mês
    for (var discard in discards) {
      final discardDate = DateTime.parse(discard['data_descarte']);
      final monthKey = '${discardDate.month}/${discardDate.year}';
      
      if (monthlyData.containsKey(monthKey)) {
        // Somar a quantidade total de itens deste descarte
        final itensDescarte = discard['itens_descarte'] as Map<String, dynamic>? ?? {};
        int totalItens = 0;
        itensDescarte.forEach((key, value) {
          final quantidade = _parseQuantidade(value);
          totalItens += quantidade; // AGORA FUNCIONA!
        });
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + totalItens;
      }
    }
    
    return monthlyData;
  }
}