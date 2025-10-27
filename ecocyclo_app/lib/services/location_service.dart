import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LocationService {
  static Future<List<Estado>> getEstados() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/location/location/estados");
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((estado) => Estado.fromJson(estado)).toList();
    } else {
      throw Exception('Falha ao carregar estados');
    }
  }

  static Future<List<Cidade>> getCidades(String uf) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/location/location/estados/$uf/cidades");
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((cidade) => Cidade.fromJson(cidade)).toList();
    } else {
      throw Exception('Falha ao carregar cidades');
    }
  }

  static Future<CepData?> getCepData(String cep) async {
    final cleanedCep = cep.replaceAll('-', '');
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/location/location/cep/$cleanedCep");
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        return CepData.fromJson(data['data']);
      }
    }
    return null;
  }
}

class Estado {
  final String sigla;
  final String nome;

  Estado({required this.sigla, required this.nome});

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      sigla: json['sigla'],
      nome: json['nome'],
    );
  }

  @override
  String toString() => '$sigla - $nome';
}

class Cidade {
  final String nome;
  final String codigo;

  Cidade({required this.nome, required this.codigo});

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      nome: json['nome'],
      codigo: json['codigo'],
    );
  }

  @override
  String toString() => nome;
}

class CepData {
  final String cep;
  final String rua;
  final String bairro;
  final String cidade;
  final String uf;

  CepData({
    required this.cep,
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory CepData.fromJson(Map<String, dynamic> json) {
    return CepData(
      cep: json['cep'] ?? '',
      rua: json['rua'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? '',
    );
  }
}