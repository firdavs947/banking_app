import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/heroText.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
    this.heroTag,
  });

  final String? heroTag;
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
    const labelStyle = TextStyle(fontSize: 13, color: AppColors.hint);
    final prefix = Icon(icon, size: 20, color: AppColors.fieldIcon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heroTag == null
            ? Text(label, style: labelStyle)
            : HeroText(
                tag: '${heroTag}_label',
                text: label,
                style: labelStyle,
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
            prefixIcon: heroTag == null
                ? prefix
                : Hero(tag: heroTag!, child: prefix),
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