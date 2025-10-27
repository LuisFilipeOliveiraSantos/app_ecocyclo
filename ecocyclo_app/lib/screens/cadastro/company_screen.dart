import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'location_screen.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';
import '../../widgets/login_textfield.dart';
import '../../widgets/cadastro/cadastro_back_button.dart';
import '../../widgets/cadastro/cadastro_next_button.dart';
import '../../widgets/cadastro/company_type_selector.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCompanyType;

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationController.dispose();
    _phoneController.dispose(); 
    super.dispose();
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
                              'Empresa',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          LoginTextField(
                            hintText: 'Nome da Empresa',
                            iconPath: 'assets/icons/company.svg',
                            controller: _companyNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Nome obrigatório';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          LoginTextField(
                            hintText: 'CNPJ (00.000.000/0000-00)',
                            iconPath: 'assets/icons/registration.svg',
                            controller: _registrationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'CNPJ obrigatório';
                              final cnpjRegex = RegExp(r'^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');
                              if (!cnpjRegex.hasMatch(value)) return 'CNPJ inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          LoginTextField(
                            hintText: "Telefone (99) 99999-9999", 
                            iconPath: 'assets/icons/phone.svg',
                            controller: _phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Telefone obrigatório';
                              final phoneRegex = RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$');
                              if (!phoneRegex.hasMatch(value)) return 'Telefone inválido';
                              return null;
                            },                 
                            ),
                            const SizedBox(height: 35),
                            CompanyTypeSelector(
                              initialValue: _selectedCompanyType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompanyType = value;
                                });
                              },
                             )
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CadastroBackButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                    ),
                    CadastroNextButton(
                      text: "Próximo",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedCompanyType == null) {
                            final snackBar = SnackBar(
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
                                    color: Colors.black.withValues(alpha: 26),
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
                                      'Selecione o tipo de empresa',
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
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LocationScreen(
                                companyName: _companyNameController.text,
                                cnpj: _registrationController.text,
                                phone: _phoneController.text,
                                companyType: _selectedCompanyType!,
                              ),
                            ),
                          );
                        }
                      },
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
