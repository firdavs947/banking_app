import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/core/network/token_storage.dart';
import 'package:banking_app22/src/features/auth/presentation/screens/reegister_screen.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/primary_button.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/snackbaar.dart';
import 'package:banking_app22/src/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:banking_app22/src/features/profile/presentation/cubit/profile_state.dart';
import 'package:banking_app22/src/features/profile/presentation/widgets/profile_header.dart';
import 'package:banking_app22/src/features/profile/presentation/widgets/profile_info_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loaded && _intro.value == 0) {
      _intro.forward();
    }
    if (state.status == ProfileStatus.loaded && state.errorMessage != null) {
      showTopSnackBar(context, state.errorMessage!);
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clear();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(portalIntro: true),
      ),
      (route) => false,
    );
  }

  void _confirmLogout() {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Confirm to log out'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(dialogContext);
              _logout();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _reveal(
    double begin,
    Widget child, {
    double dy = 24,
    double fromScale = 1.0,
  }) {
    return Reveal(
      animation: _intro,
      begin: begin,
      end: begin + 0.35,
      dy: dy,
      fromScale: fromScale,
      child: child,
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(CupertinoIcons.square_arrow_right),
        label: const Text(
          'Log out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: _onState,
          builder: (context, state) {
            final profile = state.profile;

            if (state.status == ProfileStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (state.status == ProfileStatus.failure || profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Something went wrong!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.hint),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Try again',
                        onPressed: () => context.read<ProfileCubit>().load(),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _reveal(
                      0,
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      dy: 16,
                    ),
                    const SizedBox(height: 24),
                    _reveal(
                      0.1,
                      Center(
                        child: ProfileHeader(
                          profile: profile,
                          uploading: state.uploading,
                          onChangeAvatar: () =>
                              context.read<ProfileCubit>().changeAvatar(),
                        ),
                      ),
                      dy: 32,
                      fromScale: 0.92,
                    ),
                    const SizedBox(height: 32),
                    _reveal(
                      0.3,
                      ProfileInfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: profile.username,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _reveal(
                      0.4,
                      ProfileInfoTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email Address',
                        value: profile.email,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _reveal(0.5, _logoutButton(), fromScale: 0.95),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}