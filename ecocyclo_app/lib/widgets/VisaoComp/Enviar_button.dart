import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EnviarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const EnviarButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                        AppColors.gradientLeft,
                        AppColors.gradientRight,
                      ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
