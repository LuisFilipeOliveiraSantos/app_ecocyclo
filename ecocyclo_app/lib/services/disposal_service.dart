import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';
import '../models/disposal_stats.dart';

class DisposalService {
  static Future<DisposalStats> getDisposalStats() async {
    try {
      final token = await AuthService.getToken();
      final companyId = await AuthService.getCompanyId();
      
      if (token == null || companyId.isEmpty) {
        return DisposalStats(inProgress: 0, finished: 0);
      }

      // Busca todos os descartes concluídos
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/company/$companyId");
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> discards = jsonDecode(response.body);
        
        return DisposalStats(
          inProgress: 0, // ← Futuramente buscamos de outra API
          finished: discards.length, // ← Já funcionando agora
        );
      } else {
        return DisposalStats(inProgress: 0, finished: 0);
      }

    } catch (e) {
      print('❌ Erro ao buscar estatísticas de descarte: $e');
      return DisposalStats(inProgress: 0, finished: 0);
    }
  }
}