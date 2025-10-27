import 'dart:io';
import 'package:flutter/material.dart';
import 'perfil_empresa_coleta.dart';

class EmpresasMockPage extends StatefulWidget {
  const EmpresasMockPage({super.key});

  @override
  State<EmpresasMockPage> createState() => _EmpresasMockPageState();
}

class _EmpresasMockPageState extends State<EmpresasMockPage> {
  String? _fotoCapturadaPath; // Caminho da foto capturada

  // Lista de empresas (dados simulados)
  final List<Map<String, dynamic>> empresas = [
    {
      "nome": "RecyclaByte",
      "slogan": "Dê um fim inteligente para o seu eletrônico",
      "avaliacao": 4.98,
      "imagemLogo": "assets/recycle.png",
      "descricao":
          "Fundada em 2015 em Recife(PE), a RecyclaByte nasceu com a missão de lidar com um dos maiores desafios da era digital: o descarte consciente de equipamentos eletrônicos. Especializada na coleta, triagem e reaproveitamento de resíduos tecnológicos, a empresa atende desde residências até grandes indústrias.",
      "endereco": 'Rua Zézio Magalhães, 199',
      "contato": '(87)4002-8922',
    },
    {
      "nome": "EcoTech Solutions",
      "slogan": "Soluções verdes para um futuro sustentável",
      "avaliacao": 4.85,
      "imagemLogo": "https://cdn-icons-png.flaticon.com/512/2821/2821648.png",
      "descricao":
          "A EcoTech Solutions é referência em inovação sustentável. Desde 2018, oferece soluções completas para o gerenciamento e reciclagem de eletrônicos, promovendo responsabilidade ambiental e tecnológica.",
      "endereco": 'Av. das Nações Verdes, 845',
      "contato": '(81)7776-2345'
    },
    {
      "nome": "GreenWave",
      "slogan": "Transformando lixo eletrônico em oportunidades",
      "avaliacao": 4.75,
      "imagemLogo": "https://cdn-icons-png.flaticon.com/512/890/890131.png",
      "descricao":
          "Com sede em São Paulo, a GreenWave trabalha para reduzir o impacto ambiental de resíduos eletrônicos. A empresa realiza coleta, separação e reciclagem de materiais com foco em reaproveitamento sustentável.",
      "endereco": 'Rua das Palmeiras, 52',
      "contato": '(11)1234-5678'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Empresas de Coleta",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: empresas.length,
              itemBuilder: (context, index) {
                final empresa = empresas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(empresa["imagemLogo"] as String),
                      radius: 25,
                    ),
                    title: Text(
                      empresa["nome"] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40),
                      ),
                    ),
                    subtitle: Text(empresa["slogan"] as String),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PerfilEmpresaColeta(
                            nome: empresa["nome"] as String,
                            slogan: empresa["slogan"] as String,
                            avaliacao: (empresa["avaliacao"] as num).toDouble(),
                            descricao: empresa["descricao"] as String,
                            imagemLogo: empresa["imagemLogo"] as String,
                            endereco: empresa['endereco'] as String,
                            contato: empresa['contato'] as String,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_fotoCapturadaPath != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "📷 Última foto tirada:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_fotoCapturadaPath!),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF004D40),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          "Abrir Câmera",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/camera');
          if (result != null && context.mounted) {
            setState(() {
              _fotoCapturadaPath = result.toString();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("📸 Foto salva em: $_fotoCapturadaPath")),
            );
          }
        },
      ),
    );
  }
}
