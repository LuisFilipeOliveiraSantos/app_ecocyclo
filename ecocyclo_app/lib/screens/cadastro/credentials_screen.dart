import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';
import '../../widgets/login_textfield.dart';
import '../../widgets/cadastro/cadastro_back_button.dart';
import '../../widgets/cadastro/cadastro_next_button.dart';
import '../../services/register_service.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({
    super.key,
    required this.cnpj,
    required this.phone,
    required this.companyType,
    required this.cep,
    required this.uf,
    required this.city,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.complement,
    required this.reference,
    required this.companyName,
  });

  final String cnpj;
  final String phone;
  final String companyType;
  final String cep;
  final String uf;
  final String city;
  final String street;
  final String number;
  final String neighborhood;
  final String complement;
  final String reference;
  final String companyName;

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false; // 👈 Bloqueio de spam

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return; // evita múltiplos cliques
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await RegisterService.register(
        name: widget.companyName,
        email: _emailController.text,
        password: _passwordController.text,
        cnpj: widget.cnpj,
        telefone: widget.phone,
        company_type: widget.companyType,
        cep: widget.cep,
        rua: widget.street,
        numero: widget.number,
        bairro: widget.neighborhood,
        cidade: widget.city,
        uf: widget.uf,
        complemento: widget.complement,
        referencia: widget.reference,
      );

      // ✅ SnackBar de sucesso
      final successSnackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientLeft, AppColors.gradientRight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cadastro realizado com sucesso!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(successSnackBar);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no cadastro: $e');
      debugPrintStack(stackTrace: stackTrace);

      final errorSnackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Falha no cadastro. Tente novamente.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientLeft,
              AppColors.gradientRight,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 48.0),
                            child: Text(
                              'Credenciais de Acesso',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          LoginTextField(
                            hintText: 'Email',
                            iconPath: 'assets/icons/email.svg',
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email obrigatório';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          LoginTextField(
                            hintText: 'Senha',
                            iconPath: 'assets/icons/password.svg',
                            obscureText: true,
                            passwordVisible: _passwordVisible,
                            onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Senha obrigatória';
                              if (value.length < 6) return 'Senha muito curta';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          LoginTextField(
                            hintText: 'Confirme a Senha',
                            iconPath: 'assets/icons/password.svg',
                            obscureText: true,
                            passwordVisible: _confirmPasswordVisible,
                            onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value != _passwordController.text) return 'Senhas não conferem';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CadastroBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : CadastroNextButton(
                            text: "Cadastrar",
                            isFinal: true,
                            onPressed: _handleRegister,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
