import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final int strength;

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    // Determina a cor e a largura da barra
    Color color;
    double percent;
    String label;

    switch (strength) {
      case 1:
        color = Colors.red;
        percent = 0.33;
        label = 'Fraca';
        break;
      case 2:
        color = Colors.orange;
        percent = 0.66;
        label = 'Média';
        break;
      case 3:
        color = Colors.green;
        percent = 1.0;
        label = 'Forte';
        break;
      default:
        color = Colors.grey;
        percent = 0.0;
        label = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra com borda arredondada e gradiente
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: 8,
                color: Colors.grey[300],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 8,
                width: MediaQuery.of(context).size.width * percent,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
