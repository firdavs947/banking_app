import 'package:banking_app22/consts/colors/app_colors.dart';
import 'package:banking_app22/presentation/home_view.dart';
import 'package:banking_app22/widgets/bank_card.dart';
import 'package:banking_app22/widgets/menu_title.dart';
import 'package:banking_app22/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<MenuItem> _items = [
    MenuItem('Account\nand Card', Icons.account_balance_wallet_rounded,
        AppColors.indigo),
    MenuItem('Transfer', Icons.swap_horiz_rounded, AppColors.pink),
    MenuItem('Withdraw', Icons.atm_rounded, AppColors.sky),
    MenuItem('Mobile\nrecharge', Icons.phone_android_rounded, AppColors.amber),
    MenuItem('Pay the\nbill', Icons.receipt_long_rounded, AppColors.teal),
    MenuItem('Credit\ncard', Icons.credit_card_rounded, AppColors.orange),
    MenuItem('Transaction\nreport', Icons.article_rounded, AppColors.indigo),
  ];

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
               SizedBox(height: 40),
               Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
               SizedBox(height: 24),
              //  BankCard(),
              HomeView(),
             
               SizedBox(height: 32),

              GridView.builder(
                shrinkWrap: true,
                physics:  NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (_, index) => MenuTile(item: _items[index]),
              ),
               SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) => setState(() => _currentIndex = index),
      // ),
    );
  }
}