// widgets/profile/logout_dialog.dart - Atualizado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.redGradient,
              ),
              child: const Icon(
                Icons.logout, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sair da conta?',
              style: GoogleFonts.inter(
                fontSize: 20, 
                fontWeight: FontWeight.w600, 
                color: AppColors.textPrimary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tem certeza que deseja sair?',
              style: GoogleFonts.inter(
                fontSize: 14, 
                color: AppColors.textSecondary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.black.withOpacity(0.1)
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: Text(
                      'Cancelar', 
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.logoutGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        onConfirm(); // Chama a função de confirmação
                        Navigator.pop(context); // Fecha o dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Sair', 
                        style: GoogleFonts.inter(
                          color: Colors.white, 
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}