import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final String iconPath;
  final bool obscureText;
  final double? width;
  final bool? passwordVisible; 
  final VoidCallback? onToggle;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? minLines; // PARÂMETRO ADICIONADO
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.obscureText = false,
    this.width,
    this.passwordVisible,
    this.onToggle,
    this.controller,
    this.validator,
    this.minLines, // PARÂMETRO ADICIONADO
    this.maxLines,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText && (passwordVisible != null ? !passwordVisible! : true),
        style: const TextStyle(color: Color.fromARGB(136, 255, 255, 255)),
        onChanged: onChanged,
        minLines: minLines ?? 1, // COMEÇA COM 1 LINHA
        maxLines: maxLines ?? (minLines != null ? null : 1), // CRESCE ATÉ O MÁXIMO
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(166, 255, 255, 255)),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.white, width: 2.0),
          ),
          suffixIcon: obscureText
              ? IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    passwordVisible! ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.white,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                    width: 20,
                    height: 20,
                  ),
                ),
        ),
      ),
    );
  }
}