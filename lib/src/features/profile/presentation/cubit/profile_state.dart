import 'package:banking_app22/src/features/profile/repository/profile_model.dart';

enum ProfileStatus { loading, loaded, failure }

class ProfileState {
  final ProfileStatus status;
  final ProfileModel? profile;
  final bool uploading;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.loading,
    this.profile,
    this.uploading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    bool? uploading,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      uploading: uploading ?? this.uploading,
      errorMessage: errorMessage,
    );
  }
}