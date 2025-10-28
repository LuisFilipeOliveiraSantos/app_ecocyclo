import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Importe seus widgets e serviços.
// O caminho pode precisar de ajuste.
import '../widgets/agendar/botao_localizacao.dart';
import '../widgets/agendar/botao_contato.dart';
import '../widgets/agendar/botao_enviar_solicitacao.dart';
import '../widgets/agendar/botao_voltar.dart';
import '../widgets/agendar/botao_chat.dart';
import '../services/auth_service.dart'; // Você precisará disso para o token

// --------------------------------------------------------------------------
// CONSTANTES DA API (COPIADO DO SEU MAP_SCREEN)
// --------------------------------------------------------------------------
class ApiConstants {
  static const String baseUrl = 'https://ecocyclo-back.onrender.com/api/v1';
  // Endpoint presumido para buscar uma empresa por ID
  static const String companyByIdBase = '$baseUrl/company'; 
}

// --------------------------------------------------------------------------
// MODELO DE DADOS (Atualizado com factory)
// --------------------------------------------------------------------------
class PerfilEmpresa {
  final String id;
  final String nome;
  final String slogan;
  final double avaliacao;
  final String descricao;
  final String imagemLogo;
  final String endereco;
  final String contato;

  PerfilEmpresa({
    required this.id,
    required this.nome,
    required this.slogan,
    required this.avaliacao,
    required this.descricao,
    required this.imagemLogo,
    required this.endereco,
    required this.contato,
  });

  // Factory para processar a resposta da API
  factory PerfilEmpresa.fromJson(Map<String, dynamic> json) {
    // Helper para construir o endereço
    String buildAddress(Map<String, dynamic> data) {
      final parts = <String>[];
      if (data['rua'] != null) parts.add(data['rua']);
      if (data['numero'] != null) parts.add(data['numero']);
      if (data['bairro'] != null) parts.add(data['bairro']);
      if (data['cidade'] != null) parts.add(data['cidade']);
      if (data['uf'] != null) parts.add(data['uf']);
      return parts.isNotEmpty ? parts.join(', ') : 'Endereço não informado';
    }

    return PerfilEmpresa(
      id: json['uuid']?.toString() ?? '',
      nome: json['nome'] ?? 'Nome da Empresa',
      // Ajuste os campos 'slogan', 'logo_url' e 'telefone'
      // conforme os nomes corretos da sua API
      slogan: json['slogan'] ?? 'Slogan da empresa',
      avaliacao: (json['rating_average'] as num?)?.toDouble() ?? 0.0,
      descricao: json['company_description'] ?? 'Sem descrição.',
      imagemLogo: json['logo_url'] ??
          'https://placehold.co/120x120/E0E0E0/9E9E9E?text=Logo',
      endereco: buildAddress(json),
      contato: json['telefone'] ?? 'Não informado',
    );
  }
}

// --------------------------------------------------------------------------
// TELA PRINCIPAL (Convertida para StatefulWidget)
// --------------------------------------------------------------------------
class PerfilEmpresaColeta extends StatefulWidget {
  // 1. A TELA AGORA RECEBE APENAS O ID
  final String empresaId;

  const PerfilEmpresaColeta({
    super.key,
    required this.empresaId,
  });

  @override
  State<PerfilEmpresaColeta> createState() => _PerfilEmpresaColetaState();
}

class _PerfilEmpresaColetaState extends State<PerfilEmpresaColeta> {
  PerfilEmpresa? _empresa;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 2. BUSCA OS DADOS DA EMPRESA AO INICIAR A TELA
    _fetchEmpresaDetails();
  }

  Future<void> _fetchEmpresaDetails() async {
    try {
      final token = await AuthService.getToken();
      if (!mounted) return;

      // 3. FAZ A CHAMADA À API USANDO O ID
      //    (Ajuste o endpoint se necessário)
      final response = await http.get(
        Uri.parse('${ApiConstants.companyByIdBase}/${widget.empresaId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _empresa = PerfilEmpresa.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar dados da empresa: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. TRATA OS ESTADOS DE CARREGAMENTO E ERRO
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00B894)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erro")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Ocorreu um erro: $_errorMessage"),
          ),
        ),
      );
    }

    if (_empresa == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erro")),
        body: const Center(
          child: Text("Empresa não encontrada."),
        ),
      );
    }

    // 5. UMA VEZ CARREGADO, CONSTROI A TELA COM OS DADOS VINDOS DA API
    final size = MediaQuery.of(context).size;
    final empresa = _empresa!; // Agora temos a empresa

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Conteúdo com rolagem
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 160),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(150),
                          topRight: Radius.circular(150),
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              empresa.nome, // USA DADO DA API
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066A2),
                              ),
                            ),
                            Text(
                              empresa.slogan, // USA DADO DA API
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF00A4A4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  empresa.avaliacao
                                      .toStringAsFixed(2), // USA DADO DA API
                                  style: const TextStyle(
                                    color: Color(0xFF0066A2),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFF0066A2), size: 18),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // 🔹 Botões Localização e Contato
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BotaoLocalizacao(
                                    endereco: empresa.endereco), // USA DADO
                                const SizedBox(width: 16),
                                BotaoContato(
                                    contato: empresa.contato), // USA DADO
                              ],
                            ),

                            const SizedBox(height: 30),

                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sobre:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066A2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              empresa.descricao, // USA DADO DA API
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.justify,
                            ),

                            const SizedBox(height: 50),

                            // 🔹 Botão Enviar Solicitação
                            BotaoEnviarSolicitacao(
                              nome: empresa.nome,
                              slogan: empresa.slogan,
                              imagemLogo: empresa.imagemLogo,
                              endereco: empresa.endereco,
                            ),

                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),

                    // 🔹 Imagem da empresa
                    Positioned(
                      top: -70,
                      left: (size.width / 2) - 65,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              NetworkImage(empresa.imagemLogo), // USA DADO
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 AppBar customizada com botões externos
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                BotaoVoltar(),
                BotaoChat(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

