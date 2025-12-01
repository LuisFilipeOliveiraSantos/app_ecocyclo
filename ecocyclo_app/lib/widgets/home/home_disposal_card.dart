import 'package:ecocyclo_app/screens/camera_page.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HomeDisposalCard extends StatelessWidget {
  final int inProgress;
  final int finished;
  final bool isLogged;

  const HomeDisposalCard({
    super.key,
    this.inProgress = 0,
    this.finished = 0,
    required this.isLogged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.gradientRight,
              AppColors.gradientLeft,
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
          crossAxisAlignment: isLogged
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [

            // ---------------------------------------
            // TÍTULO DEPENDENDO DO LOGIN
            // ---------------------------------------
            Text(
              isLogged
                  ? "Descartes"
                  : "Efetue login para realizar descarte",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: AppColors.white,
              ),
            ),

            const SizedBox(height: 8),

            // ---------------------------------------
            // SE LOGADO, MOSTRA MÉTRICAS
            // ---------------------------------------
            if (isLogged) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Em andamento",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inProgress.toString(),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Finalizados",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        finished.toString(),
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 24),

            // ---------------------------------------
            // BOTÃO
            // ---------------------------------------
            Center(
              child: SizedBox(
                width: screenWidth * 0.6,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (!isLogged) {
                      Navigator.pushNamed(context, '/login');
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CameraPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLogged ? "Realizar Descarte +" : "Efetuar Login",
                    style: const TextStyle(fontSize: 16),
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
