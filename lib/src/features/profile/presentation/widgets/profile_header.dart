import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/profile/repository/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.uploading,
    required this.onChangeAvatar,
  });

  final ProfileModel profile;
  final bool uploading;
  final VoidCallback onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    final url = profile.avatarUrl;
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: AppColors.primarySoft,
              backgroundImage: url == null ? null : NetworkImage(url),
              child: url == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onChangeAvatar,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: uploading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.username,
          style: const TextStyle(
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(fontSize: 15, color: AppColors.hint),
        ),
      ],
    );
  }
}