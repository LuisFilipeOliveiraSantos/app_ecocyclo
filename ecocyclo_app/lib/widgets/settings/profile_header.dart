// widgets/profile/profile_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.mainGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16, 
        bottom: 16, 
        left: 20, 
        right: 20
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios, 
              color: AppColors.loginTextPrimary, 
              size: 20
            ),
          ),
          Expanded(
            child: Text(
              'Meu Perfil', 
              style: GoogleFonts.inter(
                fontSize: 20, 
                fontWeight: FontWeight.w600, 
                color: AppColors.loginTextPrimary
              ), 
              textAlign: TextAlign.center
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}