import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/presentation/home_view.dart';
import 'package:banking_app22/src/features/auth/presentation/screens/reegister_screen.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/widgets/menu_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _routeAnimation;
  bool _attached = false;

  static const List<MenuItem> _items = [
    MenuItem(
      'Account\nand Card',
      Icons.account_balance_wallet_rounded,
      AppColors.indigo,
    ),
    MenuItem('Transfer', Icons.swap_horiz_rounded, AppColors.pink),
    MenuItem('Withdraw', Icons.atm_rounded, AppColors.sky),
    MenuItem('Mobile\nrecharge', Icons.phone_android_rounded, AppColors.amber),
    MenuItem('Pay the\nbill', Icons.receipt_long_rounded, AppColors.teal),
    MenuItem('Credit\ncard', Icons.credit_card_rounded, AppColors.orange),
    MenuItem('Transaction\nreport', Icons.article_rounded, AppColors.indigo),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attached) return;
    _attached = true;
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _controller.forward();
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
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_onRouteAnimation);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Reveal(
                animation: _controller,
                begin: 0.0,
                end: 0.35,
                dy: 20,
                child: Row(
                  children: [
                    const Text(
                      'Good Morning',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (dialogContext) => CupertinoAlertDialog(
                            title: const Text('Confirm to log out'),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Cancel'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  
                                  const storage = FlutterSecureStorage();
                                  await storage.delete(key: 'jwt');

                                  if (!context.mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Confirm',
                                  style: TextStyle(color: AppColors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: AppColors.red,
                            ),
                          ),
                          Icon(CupertinoIcons.back, color: AppColors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Reveal(
                animation: _controller,
                begin: 0.12,
                end: 0.58,
                dy: 40,
                fromScale: 0.95,
                child: const HomeView(),
              ),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (_, index) {
                  final begin = 0.34 + index * 0.055;
                  return Reveal(
                    animation: _controller,
                    begin: begin,
                    end: begin + 0.3,
                    dy: 18,
                    fromScale: 0.85,
                    child: MenuTile(item: _items[index]),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}