import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class AnalyzeService {
  static Future<List<String>> analyzeImage(Uint8List bytes, String fileName) async {
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

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody);

        // "['monitor', 'laptop', ...]" -> remove colchetes e aspas -> vira lista
        final rawString = json["data"] as String;
        final cleaned = rawString.replaceAll("[", "").replaceAll("]", "").replaceAll("'", "");
        final list = cleaned.split(",").map((item) => item.trim()).toList();

        return list;
      } else {
        throw Exception("Erro ${response.statusCode}: $responseBody");
      }
    } catch (e) {
      print("❌ Erro em AnalyzeService: $e");
      rethrow;
    }
  }
}
