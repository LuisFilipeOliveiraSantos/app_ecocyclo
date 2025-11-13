// widgets/profile/profile_text_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool isRequired; // ✅ NOVO: campo obrigatório

  const ProfileTextField({
    super.key, 
    required this.label, 
    required this.controller, 
    this.maxLines = 1, 
    this.isPassword = false, 
    this.keyboardType = TextInputType.text,
    this.isRequired = false, // ✅ NOVO
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label, 
              style: GoogleFonts.inter(
                fontSize: 14, 
                fontWeight: FontWeight.w500, 
                color: AppColors.textPrimary
              )
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500, 
                  color: AppColors.gradientRedLeft
                )
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: isPassword ? 1 : maxLines,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 15, 
            color: AppColors.textPrimary
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: Colors.grey.shade300)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: AppColors.secondary, width: 2)
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 14
            ),
          ),
        ),
      ],
    );
  }
}