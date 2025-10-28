import 'package:flutter/material.dart';

class AppColors {
  // Gradiente principal (fundo)
  static const Color gradientLeft = Color(0xFF0C3A63);
  static const Color gradientRight = Color(0xFF00978A);

  //gradiente vermelho
  static const gradientRedLeft = Color(0xFFE44B4B);
  static const gradientRedRight = Color(0xFFAA2222);

  // Gradiente botão "Sair da conta"
  static const LinearGradient logoutGradient = LinearGradient(
    colors: [Color(0xFFAA2222), Color(0xFF0C3A63)],
  );

  // Cores principais
  static const Color primary = Color(0xFF0C3A63);
  static const Color secondary = Color(0xFF028783);   // botão verde

  // Fundo geral
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Colors.white;

  // Textos
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF555555);

  // Textos do login (sobre fundo escuro)
  static const Color loginTextPrimary = Colors.white;
  static const Color loginTextSecondary = Colors.white70;

  // Botão do Onboarding
  static const Color onboardingButton = secondary;
}
