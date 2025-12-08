import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../theme/app_colors.dart'; // Ajuste o caminho conforme sua estrutura real
import '../../models/filter_details.dart';

/// Widget para exibir um card de filtro clicável e selecionável (na lista detalhada).
class SelectableFilterCard extends StatelessWidget {
  final String filterName;
  final FilterDetails details;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableFilterCard({
    super.key,
    required this.filterName,
    required this.details,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const radioColor = AppColors.secondary;
    
    final Widget filterIconContainer = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.5), 
            width: 1.0, 
          ),
        ),
        child: SvgPicture.asset(
          details.iconPath, 
          width: 28, 
          height: 28,
        ),
      );


    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? radioColor.withOpacity(0.5) : AppColors.background, 
            width: isSelected ? 2 : 1
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filterIconContainer,
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      details.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, 
                  color: radioColor, 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
