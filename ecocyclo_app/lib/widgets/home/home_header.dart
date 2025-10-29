import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String companyName;
  final VoidCallback onProfilePressed;

  const HomeHeader({
    super.key,
    required this.companyName,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Define uma altura base e garante limites mínimo e máximo
    final headerHeight = screenHeight.clamp(600, 1200) * 0.22;

    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientRight,
            AppColors.gradientLeft,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(90),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Linha superior (logo + ícone)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ecocyclo",
                style: TextStyle(
                  color: AppColors.white.withAlpha(179),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              GestureDetector(
                onTap: onProfilePressed,
                child: SvgPicture.asset(
                  "assets/icons/person.svg",
                  width: 46,
                  height: 46,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),

          // Mensagem "Olá, empresa"
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              "Olá, $companyName",
              style: TextStyle(
                color: AppColors.white.withAlpha(200),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}