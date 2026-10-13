import 'dart:io';

import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/cubit/upload_cubit.dart';
import 'package:banking_app22/src/features/auth/presentation/cubit/upload_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileAvatarUpdateWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final ValueChanged<File?>? onPicked;

  const ProfileAvatarUpdateWidget({
    super.key,
    this.imageUrl,
    this.radius = 35.0,
    this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadCubit(),
      child: BlocConsumer<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state.status == UploadStatus.success) {
            onPicked?.call(state.image);
          }
        },
        builder: (context, state) {
          ImageProvider? imageProvider;
          if (state.status == UploadStatus.success && state.image != null) {
            imageProvider = FileImage(state.image!);
          } else if (imageUrl != null && imageUrl!.isNotEmpty) {
            imageProvider = NetworkImage(imageUrl!);
          }

          return Stack(
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.primary,
                        size: radius,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => context.read<UploadCubit>().pickImage(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: radius * 0.8,
                    width: radius * 0.8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: state.status == UploadStatus.loading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: radius * 0.35,
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}