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
    return Container(
      height: 229,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          bottom: Radius.circular(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ecocyclo",
                style: TextStyle(
                  color: AppColors.white.withAlpha(179),
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: onProfilePressed,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: SvgPicture.asset(
                      "assets/icons/person.svg",
                      width: 40,
                      height: 45,
                      colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "Olá, $companyName",
            style: TextStyle(
              color: AppColors.white.withAlpha(179),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
