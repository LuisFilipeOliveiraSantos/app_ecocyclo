import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import '../../theme/app_colors.dart';

final logger = Logger();

class SettingsMenuButton extends StatelessWidget {
  final String text;
  final String? svgIconPath;
  final LinearGradient? textGradient;
  final VoidCallback? onPressed;

  const SettingsMenuButton({
    super.key,
    required this.text,
    this.svgIconPath,
    this.textGradient,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Padding ajustado para full-width
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onPressed ?? () => logger.i("$text clicado!"),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gradientRight, AppColors.gradientLeft],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Row(
                children: [
                  // 1. GARANTE O ESPAÇAMENTO DO ÍCONE (Sempre presente)
                  Opacity(
                    opacity: svgIconPath != null ? 1.0 : 0.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (svgIconPath != null)
                          SvgPicture.asset(
                            svgIconPath!,
                            width: 30,
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gradientLeft,
                              BlendMode.srcIn,
                            ),
                          ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),

                  // 2. TEXTO COM ALINHAMENTO CONDICIONAL
                  Expanded(
                    child: Align(
                      // 🌟 MUDANÇA AQUI: ALINHAMENTO CONDICIONAL 🌟
                      // Se tem ícone, desloca para a esquerda (-0.15).
                      // Se NÃO tem ícone, centraliza (0.0).
                      alignment: svgIconPath != null
                          ? const Alignment(-0.15, 0)
                          : const Alignment(0.0, 0),
                      child: textGradient != null
                          ? ShaderMask(
                              shaderCallback: (bounds) =>
                                  textGradient!.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.gradientRight, AppColors.gradientLeft],
                              ).createShader(bounds),
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}