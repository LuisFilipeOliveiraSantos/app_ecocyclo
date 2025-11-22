// lib/services/discard_report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'item_reference_service.dart';
import 'environmental_report_service.dart';

class DiscardReportService {
  static Map<String, dynamic>? _cachedItemsData;
  
  static Future<List<dynamic>> getCompanyDiscards(String companyId) async {
    print('🔍 Buscando TODOS os descartes da empresa: $companyId');
    
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
        
        // Carregar dados dos itens do backend se ainda não estiverem em cache
        if (_cachedItemsData == null) {
          _cachedItemsData = await ItemReferenceService.getAvailableItems();
          print('💾 Dados em cache: ${_cachedItemsData != null}');
        }
        
        return data;
      } else {
        print('❌ Erro ${response.statusCode}: ${response.body}');
        throw Exception('Falha ao carregar descartes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro na requisição: $e');
      throw Exception('Erro ao carregar descartes: $e');
    }
  }

  // Processar descartes para criar/atualizar relatório
  static Future<Map<String, dynamic>> processDiscardsForReport(String companyId) async {
    try {
      // Buscar descartes da empresa
      final discards = await getCompanyDiscards(companyId);
      
      // Processar itens para o formato do relatório
      Map<String, int> itensProcessados = {};
      
      for (var discard in discards) {
        final itensDescarte = discard['itens_descarte'] as Map<String, dynamic>? ?? {};
        
        itensDescarte.forEach((itemName, itemData) {
          final quantidade = _parseQuantidade(itemData);
          final normalizedName = itemName.toLowerCase().trim();
          
          itensProcessados[normalizedName] = (itensProcessados[normalizedName] ?? 0) + quantidade;
        });
      }
      
      print('📊 Itens processados para relatório: $itensProcessados');
      
      // Criar ou atualizar relatório
      final reportResult = await EnvironmentalReportService.createOrUpdateReport(
        companyId, 
        itensProcessados
      );
      
      return reportResult;
    } catch (e) {
      print('❌ Erro ao processar descartes para relatório: $e');
      throw Exception('Erro ao gerar relatório: $e');
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
    
    // DEBUG: Verificar cache antes de processar
    print('🔍 Cache antes do processamento:');
    print(' - Cache existe: ${_cachedItemsData != null}');
    if (_cachedItemsData != null) {
      print(' - Fonte: ${_cachedItemsData!['fonte']}');
      print(' - Total itens: ${_cachedItemsData!['total_itens_cadastrados']}');
    }
    
    for (var discard in discards) {
      final itensDescarte = discard['itens_descarte'] as Map<String, dynamic>? ?? {};
      
      itensDescarte.forEach((itemName, itemData) {
        final quantidade = _parseQuantidade(itemData);
        
        final itemInfo = _getItemInfoFromBackend(itemName, quantidade);
        
        // DEBUG: Mostrar informações do item processado
        print('🔄 Item processado: $itemName');
        print('   - Nome final: ${itemInfo['name']}');
        print('   - Taxa reciclagem: ${itemInfo['recyclingRate']}%');
        print('   - Risco: ${itemInfo['risk']}');
        print('   - Preço range: ${itemInfo['priceRange']}');
        
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
    
    print('🔄 Total de itens processados: ${processedItems.length}');
    return processedItems;
  }

  // ✅ MÉTODO ATUALIZADO: Buscar informações do item do backend
  static Map<String, dynamic> _getItemInfoFromBackend(String rawName, int quantity) {
    final itemsData = _cachedItemsData?['valores_referencia'] ?? {};
    
    // DEBUG: Verificar estrutura dos dados
    print('📊 Estrutura dos dados do backend:');
    print(' - ItemsData vazio: ${itemsData.isEmpty}');
    print(' - Chaves disponíveis: ${itemsData.keys}');
    print(' - Item buscado: "$rawName"');
    
    // Normalizar nome do item
    final normalizedName = rawName.toLowerCase().trim();
    
    // Mapear sinônimos para os nomes do backend
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

    var itemKey = normalizedName;
    if (synonyms.containsKey(normalizedName)) {
      itemKey = synonyms[normalizedName]!;
      print('   🔄 Sinônimo mapeado: $normalizedName -> $itemKey');
    }

    // Buscar dados do item no backend
    final itemData = itemsData[itemKey];
    
    if (itemData == null) {
      print('   ⚠️  Item "$itemKey" não encontrado no backend');
      throw Exception('Item "$itemKey" não encontrado na base de dados');
    } else {
      print('   ✅ Item "$itemKey" encontrado: $itemData');
    }

    // Calcular valores
    final minPrice = (itemData['valor_min'] as double?) ?? 5.0;
    final maxPrice = (itemData['valor_max'] as double?) ?? 15.0;
    final averagePrice = (minPrice + maxPrice) / 2;
    final totalPrice = averagePrice * quantity;

    // Calcular taxa de reaproveitamento média
    final reaproveitamentoMin = (itemData['reaproveitamento_min'] as double?) ?? 70.0;
    final reaproveitamentoMax = (itemData['reaproveitamento_max'] as double?) ?? 80.0;
    final recyclingRate = (reaproveitamentoMin + reaproveitamentoMax) / 2;

    // Converter risco do backend
    final backendRisk = (itemData['risco'] as String?) ?? 'medio';
    final risk = ItemReferenceService.convertRiskLevel(backendRisk);

    return {
      'name': _formatItemName(itemKey),
      'recyclingRate': recyclingRate,
      'price': totalPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'risk': risk,
      'riskLevel': _getRiskLevelNumber(risk),
      'observations': _getObservationsForItem(itemKey),
      'icon': ItemReferenceService.getIconForItem(itemKey),
      'priceRange': 'R\$${minPrice.toStringAsFixed(2)} - R\$${maxPrice.toStringAsFixed(2)}',
    };
  }

  // Método auxiliar para formatar nome do item
  static String _formatItemName(String itemKey) {
    final nameMap = {
      'laptop': 'Laptop',
      'celular': 'Celular',
      'tablet': 'Tablet',
      'monitor': 'Monitor',
      'teclado': 'Teclado',
      'mouse': 'Mouse',
      'headset': 'Headset',
      'cpu': 'CPU',
      'placa_mae': 'Placa-mãe',
      'controle_remoto': 'Controle Remoto',
    };
    
    return nameMap[itemKey] ?? itemKey;
  }

  // Método auxiliar para obter nível de risco numérico
  static int _getRiskLevelNumber(String risk) {
    switch (risk) {
      case 'Alto':
        return 3;
      case 'Médio':
        return 2;
      case 'Baixo':
        return 1;
      default:
        return 2;
    }
  }

  // Método auxiliar para observações
  static String _getObservationsForItem(String itemKey) {
    final observationsMap = {
      'laptop': 'Contém cobre, alumínio e pequenas quantidades de metais nobres.',
      'celular': 'Baterias e placas têm alto valor de metais preciosos.',
      'tablet': 'Similar ao celular, mas com menor densidade de metais.',
      'monitor': 'Vidro e metais podem ser reaproveitados.',
      'teclado': 'Valor pequeno, composto majoritariamente por plástico.',
      'mouse': 'Pouco material metálico recuperável.',
      'headset': 'Plástico e cobre; valor baixo.',
      'cpu': 'Metais estruturais (aço, alumínio) e placas de alto valor.',
      'placa_mae': 'Contém ouro, prata, cobre e estanho — item mais valioso por peso.',
      'controle_remoto': 'Pouco metal, alto teor de plástico.',
    };
    
    return observationsMap[itemKey] ?? 'Item eletrônico genérico para descarte.';
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
          totalItens += quantidade;
        });
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + totalItens;
      }
    }
    
    return monthlyData;
  }
}