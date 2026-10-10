import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardField extends StatelessWidget {
  const CardField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.hint),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onSubmitted,
          cursorColor: AppColors.primary,
          style: const TextStyle(fontSize: 14, color: AppColors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.fieldIcon),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.red),
            ),
            errorStyle: const TextStyle(color: AppColors.red),
          ),
        ),
      ],
    );
  }
}