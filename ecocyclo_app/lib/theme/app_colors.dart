import 'package:flutter/material.dart';

class AppColors {
  // Gradiente principal (fundo)
  static const Color gradientLeft = Color(0xFF0C3A63);
  static const Color gradientRight = Color(0xFF00978A);

  // Gradiente principal pronto para uso
  static const LinearGradient mainGradient = LinearGradient(
    colors: [gradientLeft, gradientRight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


  static const Color error = Color(0xFFE44B4B); // mesmo vermelho do gradiente


  // Gradiente vermelho (usado em botões de alerta)
  static const Color gradientRedLeft = Color(0xFFE44B4B);
  static const Color gradientRedRight = Color(0xFFAA2222);

  // Gradiente vermelho pronto para uso (nome redGradient)
  static const LinearGradient redGradient = LinearGradient(
    colors: [gradientRedLeft, gradientRedRight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente botão "Sair da conta" (mantive caso já use esse nome)
  static const LinearGradient logoutGradient = LinearGradient(
    colors: [Color(0xFFAA2222), Color(0xFF0C3A63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
