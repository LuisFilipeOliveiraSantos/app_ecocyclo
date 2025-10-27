// lib/widgets/home/home_disposal_card.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '/screens/empresas_mock_page.dart';


class HomeDisposalCard extends StatelessWidget {
  const HomeDisposalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient( // Use const aqui, pois colors agora são estáticos
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.gradientRight, // Usando o novo AppColors
              AppColors.gradientLeft,  // Usando o novo AppColors
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Descartes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.white, // Usando o novo AppColors
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  children: [
                    Text(
                      "Em andamento",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: AppColors.white, // Usando o novo AppColors
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("2", style: TextStyle(color: AppColors.white)), // Usando o novo AppColors
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Finalizadas",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: AppColors.white, // Usando o novo AppColors
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("2", style: TextStyle(color: AppColors.white)), // Usando o novo AppColors
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmpresasMockPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white, // Usando o novo AppColors
                    foregroundColor: AppColors.secondary, // Usando o novo AppColors
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Realizar Descarte +",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}