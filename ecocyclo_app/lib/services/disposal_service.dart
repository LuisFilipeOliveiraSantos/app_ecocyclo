import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';
import '../models/disposal_stats.dart';

class DisposalService {
  // Função futura para buscar descartes
  static Future<DisposalStats> getDisposalStats() async {
    final token = await AuthService.getToken();
    if (token == null) return DisposalStats(inProgress: 0, finished: 0);

    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/company/disposals/stats");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DisposalStats.fromJson(data);
    } else {
      // Retorna 0 caso a rota ainda não exista
      return DisposalStats(inProgress: 0, finished: 0);
    }
  }
}
