import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_indicator.dart';

class Informativa2Screen extends StatelessWidget {
  const Informativa2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fundo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.gradientRight,
                  AppColors.gradientLeft,
                ],
              ),
            ),
          ),

          // Parte branca (BORDA PRETA REMOVIDA)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration( // Alterado para const
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(150.0),
                  topRight: Radius.circular(150.0),
                ),
                // REMOVIDA A BORDA PRETA: border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      // ALTURA AJUSTADA para 120 (para subir o texto e compensar a imagem)
                      const SizedBox(height: 120),

                      // Título
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Acompanhe e obtenha\n relatórios completos sobre\n seus descartes',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Subtítulo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Acompanhe o impacto ambiental e\n obtenha relatórios detalhados para\n comprovar ações sustentáveis, melhorar\n processos internos e fortalecer sua\n imagem perante clientes e parceiros.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Indicadores de página
                      const CustomIndicator(activeIndex: 1, total: 2),
                      const SizedBox(height: 20),

                      // Botão "Começar"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: SizedBox(
                          width: 350,
                          height: 65,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/home');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.5),
                              ),
                            ),
                            child: const Text(
                              'Começar',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ÍCONE: CARACTERÍSTICAS ORIGINAIS MANTIDAS (Sombra e ClipRRect) + Posição/Tamanho Ajustados
          Positioned(
            // POSIÇÃO AJUSTADA para 60.0 (mais para cima)
            top: 120.0, 
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    // Sombra original mantida
                    BoxShadow(
                      color: Colors.black.withAlpha((0.25 * 255).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/graf.jpg',
                    // TAMANHO AJUSTADO para 250 (estava em 200)
                    width: 160, 
                    height: 160, // Adicionando altura para garantir a proporção 1:1
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Botão de voltar
          Positioned(
            top: 40.0,
            left: 20.0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}