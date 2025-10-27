import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecocyclo_app/services/location_service.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';

class EstadoDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const EstadoDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  State<EstadoDropdown> createState() => _EstadoDropdownState();
}

class _EstadoDropdownState extends State<EstadoDropdown> {
  List<Estado> _estados = [];
  bool _isLoading = true;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _loadEstados();
  }

  Future<void> _loadEstados() async {
    try {
      final estados = await LocationService.getEstados();
      setState(() {
        _estados = estados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          value: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged(newValue);
          },
          validator: widget.validator,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Selecione o estado',
          ),
          items: _isLoading
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Carregando estados...'),
                  ),
                ]
              : [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Selecione o estado'),
                  ),
                  ..._estados.map((Estado estado) {
                    return DropdownMenuItem<String>(
                      value: estado.sigla,
                      child: Text(
                        '${estado.sigla} - ${estado.nome}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.gradientLeft,
                        ),
                      ),
                    );
                  }).toList(),
                ],
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.gradientLeft,
          ),
        ),
      ),
    );
  }
}