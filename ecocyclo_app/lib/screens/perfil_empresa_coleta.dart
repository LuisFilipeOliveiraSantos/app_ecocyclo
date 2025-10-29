import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Adicione este pacote
import '../widgets/agendar/botao_localizacao.dart';
import '../widgets/agendar/botao_contato.dart';
import '../widgets/agendar/botao_enviar_solicitacao.dart';
import '../widgets/agendar/botao_voltar.dart';
import '../widgets/agendar/botao_chat.dart';

class PerfilEmpresaColeta extends StatelessWidget {
  final Map<String, int> geminiItens;
  final String nome;
  final String slogan;
  final double avaliacao;
  final String descricao;
  final String imagemLogo; // agora pode ser URL ou asset path
  final String endereco;
  final String contato;

  const PerfilEmpresaColeta({
    super.key,
    required this.geminiItens,
    required this.nome,
    required this.slogan,
    required this.avaliacao,
    required this.descricao,
    required this.imagemLogo,
    required this.endereco,
    required this.contato,
  });

  // Método para verificar se é uma URL
  bool get _isNetworkImage {
    return imagemLogo.startsWith('http://') || 
           imagemLogo.startsWith('https://');
  }

  // Método para verificar se é SVG
  bool get _isSvg {
    return imagemLogo.toLowerCase().endsWith('.svg');
  }

  // Widget para carregar a imagem
  Widget _buildLogoImage() {
    if (_isNetworkImage) {
      // Se for uma URL
      if (_isSvg) {
        // SVG de rede
        return SvgPicture.network(
          imagemLogo,
          fit: BoxFit.contain,
          width: 120,
          height: 120,
          placeholderBuilder: (context) => Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Icon(Icons.business, color: Colors.grey, size: 40),
          ),
        );
      } else {
        // Imagem normal de rede com cache
        return CachedNetworkImage(
          imageUrl: imagemLogo,
          fit: BoxFit.contain,
          width: 120,
          height: 120,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0066A2),
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.business, color: Colors.grey, size: 40),
          ),
        );
      }
    } else {
      // Se for asset local
      if (_isSvg) {
        // SVG local
        return SvgPicture.asset(
          imagemLogo,
          fit: BoxFit.contain,
          width: 120,
          height: 120,
        );
      } else {
        // Imagem local
        return Image.asset(
          imagemLogo,
          fit: BoxFit.contain,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.business, color: Colors.grey, size: 40),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente azul
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B894), Color(0xFF0066A2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Conteúdo rolável
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 160),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 🔹 Fundo branco com arco
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: size.height - 160, // ocupa toda a tela
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(150),
                          topRight: Radius.circular(150),
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Nome e slogan
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

                            // Avaliação
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

                            // Botões Localização e Contato
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BotaoLocalizacao(endereco: endereco),
                                const SizedBox(width: 16),
                                BotaoContato(contato: contato),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Sobre
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

                            // Botão Enviar Solicitação
                            BotaoEnviarSolicitacao(
                              geminiItens: geminiItens,
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
                          backgroundColor: Colors.grey[200],
                          child: ClipOval(
                            child: _buildLogoImage(),
                          ),
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