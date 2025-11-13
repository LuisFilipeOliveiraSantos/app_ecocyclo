import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ProfileLoader extends StatelessWidget {
  const ProfileLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
    );
  }
}
