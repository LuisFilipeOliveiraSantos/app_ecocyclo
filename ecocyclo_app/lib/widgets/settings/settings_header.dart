import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  final String companyName;

  const SettingsHeader({super.key, required this.companyName});

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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(100)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo_teknova.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/generic.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              companyName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 30,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
