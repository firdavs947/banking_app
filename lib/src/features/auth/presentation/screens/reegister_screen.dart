import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/auth/presentation/cubit/register_cubit.dart';
import 'package:banking_app22/src/features/auth/presentation/cubit/register_state.dart';
import 'package:banking_app22/screens/main_screen.dart';
import 'package:banking_app22/src/features/auth/presentation/screens/signIn_Screen.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/hero.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/heroText.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/textformfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.portalIntro = false});

  final bool portalIntro;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  late final AnimationController _intro;
  Animation<double>? _routeAnimation;
  bool _attached = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      value: widget.portalIntro ? 0.0 : 1.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attached || !widget.portalIntro) return;
    _attached = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _intro.forward();
      return;
    }
    _routeAnimation = animation;
    animation.addListener(_onRouteAnimation);
  }

  void _onRouteAnimation() {
    final animation = _routeAnimation;
    if (animation == null) return;
    if (animation.value >= 0.35) {
      animation.removeListener(_onRouteAnimation);
      _routeAnimation = null;
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_onRouteAnimation);
    _intro.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<RegisterCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _nameController.text.trim(),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state.status == RegisterStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'Can not register the user!',
                  ),
                ),
              );
            } else if (state.status == RegisterStatus.authentificated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 56),
                        Center(
                          child: Reveal(
                            animation: _intro,
                            begin: 0.0,
                            end: 0.3,
                            dy: 24,
                            fromScale: 0.8,
                            child: Hero(
                              tag: 'Icon',
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: AppColors.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_rounded,
                                  size: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Reveal(
                          animation: _intro,
                          begin: 0.08,
                          end: 0.38,
                          dy: 20,
                          child: const HeroText(
                            tag: 'auth_title',
                            text: 'Create Account',
                            style: TextStyle(
                              fontSize: 32,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Reveal(
                          animation: _intro,
                          begin: 0.14,
                          end: 0.44,
                          dy: 20,
                          child: const HeroText(
                            tag: 'auth_subtitle',
                            text: 'Sign up to open your accounts and cards',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: AppColors.hint,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        Reveal(
                          animation: _intro,
                          begin: 0.22,
                          end: 0.55,
                          dy: 24,
                          child: AuthField(
                            label: 'Full Name',
                            controller: _nameController,
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            validator: _validateName,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Reveal(
                          animation: _intro,
                          begin: 0.3,
                          end: 0.63,
                          dy: 24,
                          child: AuthField(
                            label: 'Email Address',
                            heroTag: 'email',
                            controller: _emailController,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Reveal(
                          animation: _intro,
                          begin: 0.38,
                          end: 0.71,
                          dy: 24,
                          child: AuthField(
                            label: 'Password',
                            heroTag: 'password',
                            controller: _passwordController,
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            onSubmitted: (_) => _submit(context),
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.fieldIcon,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Reveal(
                          animation: _intro,
                          begin: 0.48,
                          end: 0.8,
                          dy: 24,
                          fromScale: 0.95,
                          child: state.status == RegisterStatus.loading
                              ? const SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: CupertinoActivityIndicator(
                                      color: AppColors.black,
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: 'auth_button',
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.28,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _submit(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.background,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        Reveal(
                          animation: _intro,
                          begin: 0.58,
                          end: 0.9,
                          dy: 16,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.hint,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    authRoute(const SigninScreen()),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}