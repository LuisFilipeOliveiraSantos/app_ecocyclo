import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MapSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBookmarkTap;

  const MapSearchBar({
    super.key,
    this.hintText = "Digite o nome da empresa...",
    this.onChanged,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.bookmark, color: AppColors.secondary),
          onPressed: onBookmarkTap,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}