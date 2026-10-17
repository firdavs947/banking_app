import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/home_view.dart';
import 'package:banking_app22/src/features/auth/presentation/screens/reegister_screen.dart';
import 'package:banking_app22/src/features/auth/presentation/widgets/reveal.dart';
import 'package:banking_app22/src/features/home/presentation/widgets/menu_title.dart';
import 'package:banking_app22/src/features/home/repository/card_model.dart';
import 'package:banking_app22/src/features/home/repository/card_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _aligncontroller;
  late final Animation<AlignmentGeometry> _alignanimation;
  late final AnimationController _controller;
  Animation<double>? _routeAnimation;
  bool _attached = false;
  bool _isDragging = false;
  double _dragProximity = 0.0; // 0.0 - далеко, 1.0 - над корзиной
  final ScrollController _scrollController = ScrollController();

  // Каскадная анимация сетки: держим весь диапазон в пределах 0..1,
  // иначе Interval падает с assertion 'begin/end <= 1.0'.
  static const double _gridStart = 0.34;
  static const double _gridWindow = 0.22;
  static final double _gridStep =
      (1.0 - _gridStart - _gridWindow) / (_items.length - 1);

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

    // --- Новые платежи и переводы (5) ---
    MenuItem('QR\npayment', Icons.qr_code_scanner_rounded, AppColors.purple),
    MenuItem(
      'Request\nmoney',
      Icons.assignment_return_rounded,
      AppColors.lightBlue,
    ),
    MenuItem('International\ntransfer', Icons.public_rounded, AppColors.cyan),
    MenuItem(
      'Loan\npayment',
      Icons.hourglass_bottom_rounded,
      AppColors.deepOrange,
    ),
    MenuItem('Split\nthe bill', Icons.call_split_rounded, AppColors.lightGreen),

    // --- Накопления и инвестиции (4) ---
    MenuItem('Savings\ngoals', Icons.savings_rounded, AppColors.green),
    MenuItem('Investments', Icons.trending_up_rounded, AppColors.emerald),
    MenuItem(
      'Currency\nexchange',
      Icons.currency_exchange_rounded,
      AppColors.lime,
    ),
    MenuItem(
      'Cashback\n& Rewards',
      Icons.card_giftcard_rounded,
      AppColors.rose,
    ),

    // --- Услуги и подписки (4) ---
    MenuItem('Insurance', Icons.verified_user_rounded, AppColors.blue),
    MenuItem(
      'Tickets\n& Travel',
      Icons.confirmation_number_rounded,
      AppColors.violet,
    ),
    MenuItem('Internet\n& TV', Icons.router_rounded, AppColors.indigoAccent),
    MenuItem('Subscriptions', Icons.autorenew_rounded, AppColors.magenta),

    // --- Безопасность и поддержка (7) ---
    MenuItem(
      'Analytics\n& Budget',
      Icons.pie_chart_rounded,
      AppColors.tealAccent,
    ),
    MenuItem(
      'Card\nsettings',
      Icons.manage_accounts_rounded,
      AppColors.blueGrey,
    ),
    MenuItem('Support\nchat', Icons.forum_rounded, AppColors.lightBlueAccent),
    MenuItem(
      'Crypto\nwallet',
      Icons.currency_bitcoin_rounded,
      AppColors.yellow,
    ),
    MenuItem('Piggy\nbank', Icons.toll_rounded, AppColors.gold),
    MenuItem(
      'Receipt\nscanner',
      Icons.document_scanner_rounded,
      AppColors.grey,
    ),
    MenuItem(
      'Notifications',
      Icons.notifications_active_rounded,
      AppColors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      _aligncontroller.value = (offset / 80).clamp(0.0, 1.0);
    });
    _aligncontroller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _alignanimation =
        Tween<AlignmentGeometry>(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).animate(
          CurvedAnimation(
            parent: _aligncontroller,
            curve: Curves.easeInOutCubic,
          ),
        );
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
    _scrollController.dispose();
    _aligncontroller.dispose();
    _routeAnimation?.removeListener(_onRouteAnimation);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Reveal(
          animation: _controller,
          begin: 0.0,
          end: 0.35,
          dy: 20,
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: AlignTransition(
              alignment: _alignanimation,
              child: const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  const SizedBox(height: 24),
                  Reveal(
                    animation: _controller,
                    begin: 0.12,
                    end: 0.58,
                    dy: 40,
                    fromScale: 0.95,
                    child: HomeView(
                      proximity: _dragProximity,
                      onDragStarted: () => setState(() => _isDragging = true),
                      onDragEnded: () => setState(() {
                        _isDragging = false;
                        _dragProximity = 0.0;
                      }),
                      onDragUpdate: (details) {
                        // Рассчитываем близость к нижней части экрана (где корзина)
                        final screenHeight = MediaQuery.of(context).size.height;
                        final dragY = details.globalPosition.dy;
                        // Начинаем превращение с 40% высоты экрана до 85%
                        final proximity =
                            ((dragY - (screenHeight * 0.4)) /
                                    (screenHeight * 0.45))
                                .clamp(0.0, 1.0);
                        if (proximity != _dragProximity) {
                          setState(() => _dragProximity = proximity);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                    itemBuilder: (_, index) {
                      final begin = (_gridStart + index * _gridStep).clamp(
                        0.0,
                        1.0,
                      );
                      return Reveal(
                        animation: _controller,
                        begin: begin,
                        end: (begin + _gridWindow).clamp(0.0, 1.0),
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
            if (_isDragging)
              Positioned(
                bottom: 120, // Поднимаем еще выше, чтобы было удобно
                left: 24,
                right: 24,
                child: Reveal(
                  animation: _controller,
                  begin: 0,
                  end: 0.2,
                  dy: 20,
                  child: DragTarget<CardModel>(
                    onWillAccept: (data) => true,
                    onAccept: (card) async {
                      // Сразу скрываем кнопку удаления, так как перетаскивание завершено
                      setState(() {
                        _isDragging = false;
                        _dragProximity = 0.0;
                      });

                      final confirmed = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text('Удалить карту?'),
                          content: Text(
                            'Вы уверены, что хотите удалить карту ${card.cardNumber}?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Отмена'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Удалить'),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await CardRepository.deleteCard(
                            documentId: card.documentID,
                          );
                          setState(() {}); // Перерисовываем HomeView
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Ошибка: $e')),
                            );
                          }
                        }
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isOver = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isOver ? 100 : 80,
                        decoration: BoxDecoration(
                          color: isOver
                              ? AppColors.red
                              : AppColors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(isOver ? 40 : 20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.red.withOpacity(0.3),
                              blurRadius: isOver ? 20 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isOver
                                    ? Icons.delete_forever
                                    : Icons.delete_outline,
                                color: Colors.white,
                                size: isOver ? 40 : 32,
                              ),
                              if (!isOver) ...[
                                const SizedBox(height: 4),
                                const Text(
                                  'Перетащите сюда для удаления',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
