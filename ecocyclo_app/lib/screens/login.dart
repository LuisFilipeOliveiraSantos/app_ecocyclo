import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/login_textfield.dart';
import '../widgets/login_button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart'; // Importa o AuthService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false; // 👈 novo controle de carregamento

  static const List<Color> _gradientColors = [
    AppColors.gradientLeft,
    AppColors.gradientRight,
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return; // 👈 evita duplo clique
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Ativa loading

    try {
      await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );

      // ✅ Mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // ✅ Navega para a tela Home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // ❌ Mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao realizar login. Verifique suas credenciais.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Desativa loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: _gradientColors,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ClipOval(
                    child: Container(
                      color: const Color(0xFFE0E0E0),
                      padding: const EdgeInsets.all(0),
                      child: Image.asset(
                        'assets/Logo.png',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Texto "Ecocyclo"
                  Text(
                    'Ecocyclo',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Texto "Bem Vindo"
                  Text(
                    'Bem Vindo',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Email
                  LoginTextField(
                    hintText: 'E-mail',
                    iconPath: 'assets/icons/person.svg',
                    width: 350,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'E-mail obrigatório';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Senha
                  LoginTextField(
                    hintText: 'Senha',
                    iconPath: 'assets/icons/password.svg',
                    obscureText: true,
                    width: 350,
                    controller: _passwordController,
                    passwordVisible: _passwordVisible,
                    onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Senha obrigatória';
                      if (value.length < 6) return 'Senha muito curta';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Botão "Logar"
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : LoginButton(
                          text: 'Logar',
                          onPressed: _handleLogin,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                          width: 350,
                          gradientColors: _gradientColors,
                        ),

                  const SizedBox(height: 15),

                  // Texto "Esqueceu a senha?"
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Esqueceu a senha?',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Texto "Não tem uma conta?"
                  Text(
                    'Não tem uma conta?',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Botão "Criar"
                  LoginButton(
                    text: 'Criar',
                    onPressed: () {
                      Navigator.pushNamed(context, '/company');
                    },
                    outlined: true,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    width: 150,
                    gradientColors: _gradientColors,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
