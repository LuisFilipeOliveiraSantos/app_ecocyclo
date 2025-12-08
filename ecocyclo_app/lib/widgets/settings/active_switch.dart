// widgets/profile/active_switch.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ActiveSwitch extends StatelessWidget {
  final bool isActive;
  final Function(bool) onChanged;

  const ActiveSwitch({
    super.key, 
    required this.isActive, 
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Conta ativa', 
            style: GoogleFonts.inter(
              fontSize: 15, 
              fontWeight: FontWeight.w500, 
              color: AppColors.textPrimary
            )
          ),
          Switch(
            value: isActive,
            onChanged: onChanged,
            activeThumbColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}