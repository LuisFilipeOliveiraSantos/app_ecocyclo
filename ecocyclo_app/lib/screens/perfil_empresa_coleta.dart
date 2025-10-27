import 'package:flutter/material.dart';
import '../widgets/agendar/botao_localizacao.dart';
import '../widgets/agendar/botao_contato.dart';
import '../widgets/agendar/botao_enviar_solicitacao.dart';
import '../widgets/agendar/botao_voltar.dart';
import '../widgets/agendar/botao_chat.dart';

class PerfilEmpresaColeta extends StatelessWidget {
  final String nome;
  final String slogan;
  final double avaliacao;
  final String descricao;
  final String imagemLogo;
  final String endereco;
  final String contato;

  const PerfilEmpresaColeta({
    super.key,
    required this.nome,
    required this.slogan,
    required this.avaliacao,
    required this.descricao,
    required this.imagemLogo,
    required this.endereco,
    required this.contato,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                              nome,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0066A2),
                              ),
                            ),
                            Text(
                              slogan,
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
                                  avaliacao.toStringAsFixed(2),
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
                                BotaoLocalizacao(endereco: endereco),
                                const SizedBox(width: 16),
                                BotaoContato(contato: contato),
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
                              descricao,
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
                              nome: nome,
                              slogan: slogan,
                              imagemLogo: imagemLogo,
                              endereco: endereco,
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
                          backgroundImage: NetworkImage(imagemLogo),
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