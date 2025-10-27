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
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCompanyType;
  List<String> _selectedTags = [];
  final List<String> _availableTags = ["venda", "doacao", "marketplace", "reuso"];

  // Nomes bonitos para exibição no frontend
  final Map<String, String> _tagDisplayNames = {
    "venda": "Venda",
    "doacao": "Doação", 
    "marketplace": "MarketPlace",
    "reuso": "Reuso",
  };

  void _handleTagSelection(String tag, bool selected) {
    setState(() {
      if (selected) {
        _selectedTags.add(tag);
      } else {
        _selectedTags.remove(tag);
      }
    });
  }

  String _getDisplayTag(String inputTag) {
    return _tagDisplayNames[inputTag] ?? inputTag;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
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
                    child: SingleChildScrollView(
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
                            const SizedBox(height: 24),

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
                            const SizedBox(height: 24),

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
                            const SizedBox(height: 24),

                            LoginTextField(
                              hintText: 'Descrição da Empresa (Opcional)',
                              iconPath: 'assets/icons/description.svg',
                              controller: _descriptionController,
                              minLines: 1,
                              maxLines: 3,
                              validator: (value) => null,
                            ),
                            const SizedBox(height: 24),

                            CompanyTypeSelector(
                              initialValue: _selectedCompanyType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompanyType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            if (_selectedCompanyType == 'coletora') ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serviços *',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Selecione o serviço oferecido pela sua empresa coletora:',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _availableTags.map((tag) {
                                        final isSelected = _selectedTags.contains(tag);
                                        return FilterChip(
                                          label: Text(
                                            _getDisplayTag(tag), // Nome bonito para exibição
                                            style: GoogleFonts.poppins(
                                              color: isSelected ? Colors.white : AppColors.gradientLeft,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            _handleTagSelection(tag, selected);
                                          },
                                          backgroundColor: Colors.white,
                                          selectedColor: AppColors.gradientLeft,
                                          checkmarkColor: Colors.white,
                                        );
                                      }).toList(),
                                    ),
                                    if (_selectedTags.isEmpty && _selectedCompanyType == 'coletora')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Selecione pelo menos uma tag',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
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
                            _showSnackBar('Selecione o tipo de empresa');
                            return;
                          }

                          if (_selectedCompanyType == 'coletora' && _selectedTags.isEmpty) {
                            _showSnackBar('Selecione pelo menos uma tag para empresa coletora');
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LocationScreen(
                                companyName: _companyNameController.text,
                                cnpj: _registrationController.text,
                                phone: _phoneController.text,
                                companyType: _selectedCompanyType!,
                                description: _descriptionController.text,
                                tags: _selectedCompanyType == 'coletora' 
                                    ? _selectedTags.toList() // Envia as tags originais em minúsculo
                                    : null,
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

  void _showSnackBar(String message) {
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
                message,
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
  }
}