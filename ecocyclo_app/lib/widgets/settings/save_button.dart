// widgets/profile/save_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const SaveButton({
    super.key, 
    required this.isSaving, 
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.secondary, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3), 
            blurRadius: 12, 
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
        ),
        child: isSaving
          ? SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(
                color: Colors.white, 
                strokeWidth: 2
              )
            )
          : Text(
              'Salvar alterações', 
              style: GoogleFonts.inter(
                fontSize: 16, 
                fontWeight: FontWeight.w600, 
                color: Colors.white
              )
            ),
      ),
    );
  }
}