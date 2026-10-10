import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCardHeader extends StatelessWidget {
  const AddCardHeader({
    super.key,
    this.title = 'Add Card',
    this.showBack = false,
  });

  final String title;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.back,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}