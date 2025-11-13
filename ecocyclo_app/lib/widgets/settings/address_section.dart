// widgets/profile/address_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'profile_text_field.dart';

class AddressSection extends StatelessWidget {
  final TextEditingController cepController;
  final TextEditingController streetController;
  final TextEditingController numberController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController complementController;
  final TextEditingController referenceController;

  const AddressSection({
    super.key,
    required this.cepController,
    required this.streetController,
    required this.numberController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    required this.complementController,
    required this.referenceController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Endereço', 
          style: GoogleFonts.inter(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            color: AppColors.textPrimary
          )
        ),
        const SizedBox(height: 16),
        ProfileTextField(label: 'CEP', controller: cepController),
        const SizedBox(height: 16),
        ProfileTextField(label: 'Rua', controller: streetController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2, 
              child: ProfileTextField(
                label: 'Número', 
                controller: numberController
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3, 
              child: ProfileTextField(
                label: 'Bairro', 
                controller: neighborhoodController
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3, 
              child: ProfileTextField(
                label: 'Cidade', 
                controller: cityController
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1, 
              child: ProfileTextField(
                label: 'UF', 
                controller: stateController
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'Complemento', 
          controller: complementController
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'Referência', 
          controller: referenceController
        ),
      ],
    );
  }
}