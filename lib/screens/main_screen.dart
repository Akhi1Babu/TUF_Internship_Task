import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dashboard_screen.dart';
import 'summary_screen.dart';
import 'category_spending_screen.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';
import '../widgets/bouncing_wrapper.dart';
import '../core/app_style.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const SummaryScreen(),
    const CategorySpendingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.getBg(context),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_currentIndex],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.primary,
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.black, size: 28.r),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppStyle.getSurface(context),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.r,
        elevation: 0,
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, Icons.home_outlined, 0),
            _buildNavItem(Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 1),
            SizedBox(width: 48.w),
            _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 2),
            _buildNavItem(Icons.settings, Icons.settings_outlined, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    final isSelected = _currentIndex == index;
    return BouncingWrapper(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(12.r),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? AppStyle.primary : AppStyle.getSubtitle(context),
          size: 28.r,
        ),
      ),
    );
  }
}
