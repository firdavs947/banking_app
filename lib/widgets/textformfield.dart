
import 'package:banking_app22/core/consts/colors/appcolors.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
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
          onFieldSubmitted: onSubmitted,
          cursorColor: AppColors.primary,
          style: const TextStyle(fontSize: 14, color: AppColors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.fieldIcon),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
            suffixIcon: suffix,
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