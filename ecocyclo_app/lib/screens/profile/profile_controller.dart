import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../models/user_update.dart';
import '../../services/update_user_service.dart';
import '../../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  // Estados
  bool isLoading = true;
  bool isLoggedIn = false;
  bool isSaving = false;
  bool showTagError = false;

  // Dados do usuário
  UserModel? user;
  String? imagePath;
  List<String> tags = [];

  // Serviços
  late CompanyService companyService;

  // Controladores de texto
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyDescriptionController = TextEditingController();
  final cepController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final complementController = TextEditingController();
  final referenceController = TextEditingController();

  // ====== Inicialização ======
  Future<void> checkLoginStatus() async {
    try {
      isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        await loadUserProfile();
      }
    } catch (_) {
      isLoggedIn = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Usuário não autenticado');

      companyService = CompanyService(token: token);
      final profileData = await companyService.getCompanyProfile();

      user = UserModel.fromApiJson(profileData);
      _updateControllersFromUser();
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ====== Atualizações ======
  void _updateControllersFromUser() {
    if (user == null) return;
    nameController.text = user!.name;
    phoneController.text = user!.phone;
    emailController.text = user!.email;
    companyDescriptionController.text = user!.companyDescription;
    cepController.text = user!.cep;
    streetController.text = user!.street;
    numberController.text = user!.number;
    neighborhoodController.text = user!.neighborhood;
    cityController.text = user!.city;
    stateController.text = user!.state;
    complementController.text = user!.complement;
    referenceController.text = user!.reference;
    tags = List.from(user!.companyCollectorTags);
    imagePath = user!.companyPhotoUrl;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imagePath = picked.path;
      notifyListeners();
    }
  }

  Future<void> saveChanges(BuildContext context) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        cepController.text.trim().isEmpty) {
      _showSnack(context, 'Preencha todos os campos obrigatórios', true);
      return;
    }

    if (tags.isEmpty) {
      showTagError = true;
      _showSnack(context, 'Selecione pelo menos uma forma de atuação', true);
      notifyListeners();
      return;
    }

    isSaving = true;
    notifyListeners();

    try {
      final updatedUser = user?.copyWith(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        companyDescription: companyDescriptionController.text.trim(),
        companyCollectorTags: tags,
        cep: cepController.text.trim(),
        street: streetController.text.trim(),
        number: numberController.text.trim(),
        neighborhood: neighborhoodController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        complement: complementController.text.trim(),
        reference: referenceController.text.trim(),
        companyPhotoUrl: imagePath,
        updatedAt: DateTime.now(),
      );

      final response = await companyService.updateCompanyProfile(updatedUser!.toUpdateJson());

      if (response.containsKey('nome') && response['nome'] == updatedUser.name) {
        await AuthService.updateLocalCompanyInfo(
            updatedUser.name, updatedUser.email);
        user = updatedUser;
        _showSnack(context, 'Alterações salvas com sucesso!', false);
      } else {
        throw Exception('A API não retornou os dados atualizados');
      }
    } catch (e) {
      _showSnack(context, 'Erro ao salvar: ${e.toString()}', true);
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }

  void _showSnack(BuildContext context, String msg, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.gradientRedLeft : AppColors.secondary,
      ),
    );
  }

  void disposeControllers() {
    for (final c in [
      nameController,
      phoneController,
      emailController,
      companyDescriptionController,
      cepController,
      streetController,
      numberController,
      neighborhoodController,
      cityController,
      stateController,
      complementController,
      referenceController,
    ]) {
      c.dispose();
    }
  }
}
