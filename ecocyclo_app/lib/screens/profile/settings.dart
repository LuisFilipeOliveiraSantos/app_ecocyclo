import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';
import 'profile_controller.dart';
import '../../widgets/settings/profile_login_prompt.dart';
import '../../widgets/settings/profile_editor.dart';
import '../../widgets/settings/profile_loader.dart';
import '../login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = ProfileController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
    controller.checkLoginStatus();
  }

  @override
  void dispose() {
    controller.disposeControllers();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    ).then((_) => controller.checkLoginStatus());
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) return const ProfileLoader();

    return controller.isLoggedIn
        ? ProfileEditor(controller: controller)
        : ProfileLoginPrompt(onLoginPressed: _navigateToLogin);
  }
}
