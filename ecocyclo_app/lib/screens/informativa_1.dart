import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_indicator.dart';

class Informativa1Screen extends StatelessWidget {
  const Informativa1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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

          // Parte branca
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.78,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(150.0),
                  topRight: Radius.circular(150.0),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 150), // mantém espaçamento original

                      // Título
                      const Text(
                        'Conecte-se com\nempresas de coleta\npersonalizadas para você',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 40), // mantém espaçamento original

                      // Subtítulo
                      const Text(
                        'Encontre facilmente empresas para\ndescartar ou doar seu equipamento\neletrônico.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 60), // mantém espaçamento original

                      // Indicador
                      const CustomIndicator(activeIndex: 0, total: 2),
                      const SizedBox(height: 20), // mantém espaçamento original

                      // Botão "Avançar"
                      SizedBox(
                        width: 350,
                        height: 65,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/informativa2');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.5),
                            ),
                          ),
                          child: const Text(
                            'Avançar',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),

                      const Spacer(), 
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Imagem central
          Positioned(
            top: 70.0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                child: Image.asset(
                  'assets/loc.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
