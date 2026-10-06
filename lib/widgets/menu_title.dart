import 'package:banking_app22/core/consts/colors/appcolors.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;

  const MenuItem(this.title, this.icon, this.color);
}

class MenuTile extends StatelessWidget {
  final MenuItem item;

  const MenuTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 26),
           SizedBox(height: 10),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style:  TextStyle(
              fontSize: 11,
              height: 1.3,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}