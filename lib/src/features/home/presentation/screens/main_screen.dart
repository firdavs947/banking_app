import 'package:banking_app22/src/core/consts/colors/appcolors.dart';
import 'package:banking_app22/src/features/home/presentation/screens/all_transactions_sccreen.dart.dart';
import 'package:banking_app22/src/features/home/presentation/screens/card_info.dart';
import 'package:banking_app22/src/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<LiquidGlassTabBarItem> _items = const [
    LiquidGlassTabBarItem(icon: CupertinoIcons.house_fill, label: 'Home'),
    LiquidGlassTabBarItem(icon: CupertinoIcons.time, label: 'History'),
    LiquidGlassTabBarItem(icon: CupertinoIcons.add, label: 'Add'),
    LiquidGlassTabBarItem(icon: CupertinoIcons.graph_square, label: 'Proggress'),
  ];

  late final List<Widget> _screens = const [
    HomeScreen(),
   AllTransactions(),
   CardInfo(),
    
    CardInfo()
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScaffold(
      body: _screens[_index],
      bottomNavigationBar: LiquidGlassTabBar(
        itemStyle: LiquidGlassTabItemStyle(
          unselectedColor: AppColors.black,
            labelFontSize: 13,
            selectedColor: AppColors.blue,
            iconSize: 28),
        items: _items,
        selectedIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: 68, 
        style: LiquidGlassStyle(
          shape: const LiquidGlassShape.continuousRoundedRectangle(
            cornerRadius: 34,
          ),
          appearance: LiquidGlassAppearance(
            blur: const LiquidGlassBlur(sigmaX: 35.0, sigmaY: 35.0),
            saturation: 1.0,
          ),
          refraction: const LiquidGlassRefraction(distortion: 0.8),
        ),
      ),
    );
  }
}