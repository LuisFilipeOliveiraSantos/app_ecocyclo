import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'credentials_screen.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';
import '../../widgets/login_textfield.dart';
import '../../widgets/cadastro/cadastro_back_button.dart';
import '../../widgets/cadastro/cadastro_next_button.dart';

class LocationScreen extends StatefulWidget {
  final String companyName;
  final String cnpj;
  final String phone;
  final String companyType;

  const LocationScreen({
    super.key,
    required this.companyName,
    required this.cnpj,
    required this.phone,
    required this.companyType,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _zipCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _referenceController.dispose();
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
                                'Localização',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            // CEP
                            LoginTextField(
                              hintText: 'CEP (00000-000)',
                              iconPath: 'assets/icons/zip.svg',
                              controller: _zipCodeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'CEP obrigatório';
                                if (!RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) return 'CEP inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Estado e Cidade em linha
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: LoginTextField(
                                    hintText: 'UF',
                                    iconPath: 'assets/icons/state.svg',
                                    controller: _stateController,
                                    validator: (value) => value == null || value.isEmpty ? 'UF obrigatório' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: LoginTextField(
                                    hintText: 'Cidade',
                                    iconPath: 'assets/icons/city.svg',
                                    controller: _cityController,
                                    validator: (value) => value == null || value.isEmpty ? 'Cidade obrigatória' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Rua, Número e Bairro em linha
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: LoginTextField(
                                    hintText: 'Rua',
                                    iconPath: 'assets/icons/address.svg',
                                    controller: _streetController,
                                    validator: (value) => value == null || value.isEmpty ? 'Rua obrigatória' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 80,
                                  child: LoginTextField(
                                    hintText: 'Nº',
                                    iconPath: 'assets/icons/number.svg',
                                    controller: _numberController,
                                    validator: (value) => value == null || value.isEmpty ? 'Número obrigatório' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: LoginTextField(
                                    hintText: 'Bairro',
                                    iconPath: 'assets/icons/neighborhood.svg',
                                    controller: _neighborhoodController,
                                    validator: (value) => value == null || value.isEmpty ? 'Bairro obrigatório' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Complemento
                            LoginTextField(
                              hintText: 'Complemento (opcional)',
                              iconPath: 'assets/icons/reference.svg',
                              controller: _complementController,
                              validator: (value) => null, // opcional
                            ),
                            const SizedBox(height: 24),

                            // Referência
                            LoginTextField(
                              hintText: 'Referência (opcional)',
                              iconPath: 'assets/icons/reference.svg',
                              controller: _referenceController,
                              validator: (value) => null, // opcional
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Botões
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CadastroBackButton(
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CadastroNextButton(
                      text: 'Próximo',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CredentialsScreen(
                                companyName: widget.companyName,
                                cnpj: widget.cnpj,
                                phone: widget.phone,
                                companyType: widget.companyType,
                                cep: _zipCodeController.text,
                                uf: _stateController.text,
                                city: _cityController.text,
                                street: _streetController.text,
                                number: _numberController.text,
                                neighborhood: _neighborhoodController.text,
                                complement: _complementController.text,
                                reference: _referenceController.text,


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
