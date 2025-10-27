import 'package:flutter/material.dart';

class BotaoVoltarPadrao extends StatelessWidget {
  final VoidCallback onPressed;
  final Color iconColor;
  final double iconSize;

  const BotaoVoltarPadrao({
    super.key,
    required this.onPressed,
    this.iconColor = Colors.white,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: iconSize),
      onPressed: onPressed,
    );
  }
}