import 'dart:io';

import 'package:banking_app22/src/features/profile/presentation/cubit/profile_state.dart';
import 'package:banking_app22/src/features/profile/repository/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> load() async {
    emit(const ProfileState(status: ProfileStatus.loading));
    try {
      final profile = await ProfileRepository.getProfile();
      emit(ProfileState(status: ProfileStatus.loaded, profile: profile));
    } on ProfileException catch (e) {
      emit(ProfileState(
        status: ProfileStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(const ProfileState(
        status: ProfileStatus.failure,
        errorMessage: 'Something went wrong!',
      ));
    }
  }

  Future<void> changeAvatar() async {
    final current = state.profile;
    if (current == null || state.uploading) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    emit(state.copyWith(uploading: true));
    try {
      await ProfileRepository.uploadAvatar(
        file: File(picked.path),
        userId: current.id,
      );
      final profile = await ProfileRepository.getProfile();
      emit(ProfileState(status: ProfileStatus.loaded, profile: profile));
    } on ProfileException catch (e) {
      emit(state.copyWith(uploading: false, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        uploading: false,
        errorMessage: 'Something went wrong!',
      ));
    }
  }
}