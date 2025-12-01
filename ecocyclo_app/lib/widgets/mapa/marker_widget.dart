import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/disposal_point.dart';
import '../../theme/app_colors.dart';

class MarkerWidget extends StatelessWidget {
  final DisposalPoint enterprise;
  final bool isSelected;

  const MarkerWidget({super.key, required this.enterprise, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final category = enterprise.categories.isNotEmpty ? enterprise.categories.first : '';
    final backgroundColor = _getColorForCategory(category);
    final iconData = _getIconForCategory(category);

    return Container(
      width: isSelected ? 60 : 50,
      height: isSelected ? 60 : 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: isSelected ? 8 : 6, offset: const Offset(0, 2))],
      ),
      child: Icon(iconData, color: Colors.white, size: isSelected ? 30 : 25),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Reciclagem':
        return AppColors.secondary;
      case 'Doação':
        return Colors.green.shade600;
      case 'MarketPlace':
        return Colors.blue.shade600;
      case 'Reuso':
        return Colors.orange.shade700;
      default:
        return AppColors.secondary;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Reciclagem':
        return Icons.recycling;
      case 'Doação':
        return Icons.volunteer_activism;
      case 'MarketPlace':
        return Icons.shopping_cart;
      case 'Reuso':
        return Icons.refresh;
      default:
        return Icons.business;
    }
  }
}
