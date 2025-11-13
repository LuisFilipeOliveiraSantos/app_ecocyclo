// widgets/profile/tag_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class TagSection extends StatelessWidget {
  final List<String> tags;
  final Function(String) onTagSelected;
  final Function(String) onTagRemoved;
  final bool showError;

  const TagSection({
    super.key, 
    required this.tags, 
    required this.onTagSelected, 
    required this.onTagRemoved,
    this.showError = false,
  });

  // Tags disponíveis com mapeamento para a API
  static const Map<String, String> availableTags = {
    'Venda': 'venda',
    'Doação': 'doacao', 
    'MarketPlace': 'marketplace',
    'Reuso': 'reuso',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags de atuação', 
          style: GoogleFonts.inter(
            fontSize: 14, 
            fontWeight: FontWeight.w500, 
            color: AppColors.textPrimary
          )
        ),
        const SizedBox(height: 8),
        
        // Mensagem de instrução
        Text(
          'Selecione as formas de atuação da sua empresa:',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        // Grid de tags disponíveis
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.entries.map((entry) {
            final String displayName = entry.key;
            final String apiValue = entry.value;
            final bool isSelected = tags.contains(apiValue);
            
            return FilterChip(
              label: Text(
                displayName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onTagSelected(apiValue);
                } else {
                  onTagRemoved(apiValue);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.secondary,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
        
        // Mensagem de erro quando não há tags selecionadas
        if (showError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.gradientRedLeft,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Selecione pelo menos uma forma de atuação',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.gradientRedLeft,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}