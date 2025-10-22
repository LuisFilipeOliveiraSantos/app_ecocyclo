import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';

class CompanyTypeSelector extends StatefulWidget {
  final Function(String) onChanged;
  final String? initialValue;

  const CompanyTypeSelector({
    super.key,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<CompanyTypeSelector> createState() => _CompanyTypeSelectorState();
}

class _CompanyTypeSelectorState extends State<CompanyTypeSelector> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue;
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
    widget.onChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Empresa',
          style: GoogleFonts.poppins(
            color: AppColors.loginTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOption(
              label: "Coletora",
              value: "coletora",
              icon: Icons.recycling_outlined,
            ),
            _buildOption(
              label: "Descartante",
              value: "descartante",
              icon: Icons.factory_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () => _selectType(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.9)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.white
                  : AppColors.loginTextSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? AppColors.white
                    : AppColors.loginTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
