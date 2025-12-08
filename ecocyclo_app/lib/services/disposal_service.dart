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

      // Busca todos os descartes da empresa
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/discards/company/$companyId");
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> discards = jsonDecode(response.body);
        
        // Calcula as estatísticas baseadas nos status
        int inProgressCount = 0;
        int finishedCount = 0;

        for (var discard in discards) {
          final status = discard['status']?.toString().toLowerCase() ?? '';
          
          // Verifica se está em andamento
          if (status == 'pendente' || status == 'confirmado' || status == 'em andamento') {
            inProgressCount++;
          } 
          // Verifica se está finalizado
          else if (status == 'completo' || status == 'cancelado') {
            finishedCount++;
          }
        }

        return DisposalStats(
          inProgress: inProgressCount,
          finished: finishedCount,
        );
      } else {
        print('❌ Erro na API: ${response.statusCode}');
        return DisposalStats(inProgress: 0, finished: 0);
      }

    } catch (e) {
      print('❌ Erro ao buscar estatísticas de descarte: $e');
      return DisposalStats(inProgress: 0, finished: 0);
    }
  }
}