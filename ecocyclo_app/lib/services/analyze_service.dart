//import 'dart:convert';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class AnalyzeService {
  /// Envia a imagem para o backend e retorna um Map<String,int> com os objetos e suas quantidades.
  static Future<Map<String, int>> analyzeImage(Uint8List bytes, String fileName) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/object_recognition/process-photo/");
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("🔍 Status: ${response.statusCode}");
      print("🔍 Body: $responseBody");

      if (response.statusCode != 200) {
        throw Exception("Erro ${response.statusCode}: $responseBody");
      }

      // ✅ Limpa a string JSON escapada
      String cleaned = responseBody.trim();

      // Remove aspas externas se existirem
      if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        cleaned = cleaned.substring(1, cleaned.length - 1);
      }

      // Substitui aspas escapadas
      cleaned = cleaned.replaceAll(r'\"', '"');

      // Decodifica JSON
      final Map<String, dynamic> decoded = jsonDecode(cleaned);

      // Garante que todos os valores sejam int
      final Map<String, int> result = decoded.map((key, value) {
        if (value is int) return MapEntry(key, value);
        if (value is String) return MapEntry(key, int.tryParse(value) ?? 0);
        return MapEntry(key, (value as num).toInt());
      });

      return result;
    } catch (e, st) {
      print("❌ Erro em AnalyzeService: $e");
      print(st);
      rethrow;
    }
  }
}




