import 'package:flutter/material.dart';
import '../../theme/app_colors.dart'; // Certifique-se que o caminho está correto

class MapHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const MapHeader({
    super.key,
    this.title = "Encontre empresas", // Valor padrão
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
            children: [
              // Botão de Voltar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95), // Leve transparência
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  tooltip: 'Voltar',
                ),
              ),
              
              const SizedBox(width: 12),

              // Pílula do Título
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}