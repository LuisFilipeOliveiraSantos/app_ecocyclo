// widgets/cadastro/cidade_dropdown.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecocyclo_app/services/location_service.dart';
import 'package:ecocyclo_app/theme/app_colors.dart';

class CidadeDropdown extends StatefulWidget {
  final String? uf;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const CidadeDropdown({
    super.key,
    required this.uf,
    this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CidadeDropdown> createState() => _CidadeDropdownState();
}

class _CidadeDropdownState extends State<CidadeDropdown> {
  List<Cidade> _cidades = [];
  bool _isLoading = false;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    if (widget.uf != null && widget.uf!.isNotEmpty) {
      _loadCidades(widget.uf!);
    }
  }

  @override
  void didUpdateWidget(CidadeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uf != oldWidget.uf && widget.uf != null && widget.uf!.isNotEmpty) {
      _loadCidades(widget.uf!);
    } else if (widget.uf == null || widget.uf!.isEmpty) {
      setState(() {
        _cidades = [];
        _selectedValue = null;
      });
    }
  }

  Future<void> _loadCidades(String uf) async {
    setState(() {
      _isLoading = true;
      _cidades = [];
      _selectedValue = null;
    });

    try {
      final cidades = await LocationService.getCidades(uf);
      setState(() {
        _cidades = cidades;
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
          onChanged: widget.uf == null || widget.uf!.isEmpty ? null : (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged(newValue);
          },
          validator: widget.validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.uf == null || widget.uf!.isEmpty 
                ? 'Selecione o estado primeiro'
                : 'Selecione a cidade',
          ),
          items: widget.uf == null || widget.uf!.isEmpty
              ? [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Selecione o estado primeiro'),
                  ),
                ]
              : _isLoading
                  ? [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Carregando cidades...'),
                      ),
                    ]
                  : [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Selecione a cidade'),
                      ),
                      ..._cidades.map((Cidade cidade) {
                        return DropdownMenuItem<String>(
                          value: cidade.nome,
                          child: Text(
                            cidade.nome,
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