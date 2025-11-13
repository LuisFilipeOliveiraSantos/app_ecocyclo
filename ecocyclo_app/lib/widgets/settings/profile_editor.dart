import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/settings/profile_header.dart';
import '../../../widgets/settings/profile_photo.dart';
import '../../../widgets/settings/profile_text_field.dart';
import '../../../widgets/settings/tag_section.dart';
import '../../../widgets/settings/address_section.dart';
import '../../../widgets/settings/save_button.dart';
import '../../../widgets/settings/logout_button.dart';
import '../../../widgets/settings/logout_dialog.dart';
import '../../screens/profile/profile_controller.dart';

class ProfileEditor extends StatelessWidget {
  final ProfileController controller;
  const ProfileEditor({super.key, required this.controller});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => LogoutDialog(onConfirm: controller.logout),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  ProfilePhoto(
                      imagePath: controller.imagePath,
                      onTap: controller.pickImage),
                  const SizedBox(height: 40),
                  ProfileTextField(label: 'Nome', controller: controller.nameController),
                  const SizedBox(height: 16),
                  ProfileTextField(label: 'Telefone', controller: controller.phoneController),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'E-mail',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    label: 'Descrição da empresa',
                    controller: controller.companyDescriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TagSection(
                    tags: controller.tags,
                    onTagSelected: (tag) {
                      if (!controller.tags.contains(tag)) {
                        controller.tags.add(tag);
                        controller.showTagError = false;
                        controller.notifyListeners();
                      }
                    },
                    onTagRemoved: (tag) {
                      controller.tags.remove(tag);
                      controller.showTagError = controller.tags.isEmpty;
                      controller.notifyListeners();
                    },
                    showError: controller.showTagError,
                  ),
                  const SizedBox(height: 24),
                  AddressSection(
                    cepController: controller.cepController,
                    streetController: controller.streetController,
                    numberController: controller.numberController,
                    neighborhoodController: controller.neighborhoodController,
                    cityController: controller.cityController,
                    stateController: controller.stateController,
                    complementController: controller.complementController,
                    referenceController: controller.referenceController,
                  ),
                  const SizedBox(height: 40),
                  SaveButton(
                    isSaving: controller.isSaving,
                    onPressed: () => controller.saveChanges(context),
                  ),
                  const SizedBox(height: 16),
                  LogoutButton(onPressed: () => _logout(context)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
