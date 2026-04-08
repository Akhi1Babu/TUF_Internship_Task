import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../models/transaction.dart';
import '../core/app_style.dart';
import '../widgets/bouncing_wrapper.dart';
import '../widgets/transaction_list_tile.dart';
import 'dart:math';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedFilter = 'W';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final user = ref.watch(authProvider).currentUser;
    final balance = ref.watch(balanceProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final saved = (totalIncome - totalExpense).clamp(0.0, double.infinity);
    final greeting = _getGreeting();

    // Calculate chart data based on selected filter
    final chartData = _getChartData(transactions);
    final double maxAmount = chartData.isEmpty ? 10 : chartData.map((e) => e['amount'] as double).reduce(max);
    final double displayMax = maxAmount < 10 ? 100 : maxAmount * 1.2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppStyle.pL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Stealth Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'PAYU ENTERPRISE',
                  style: TextStyle(
                    color: AppStyle.getSubtitle(context), 
                    fontSize: AppStyle.fXS, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppStyle.getSurface(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          color: AppStyle.getOnSurface(context), 
                          fontSize: AppStyle.fS, 
                          fontWeight: FontWeight.w500
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(radius: 10, backgroundColor: AppStyle.secondary, child: Text('M', style: TextStyle(fontSize: 8, color: Colors.white))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text(greeting, style: TextStyle(color: AppStyle.getOnSurface(context).withValues(alpha: 0.4), fontSize: AppStyle.fM)),
          Text('YOUR TOTAL', style: TextStyle(color: AppStyle.getOnSurface(context).withValues(alpha: 0.7), fontSize: AppStyle.fXL, fontWeight: FontWeight.w300, letterSpacing: 1)),
          Text('BALANCE', style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 36.sp, fontWeight: FontWeight.bold, height: 0.9)),
          
          const SizedBox(height: 32),

          // Stealth Balance Card
          Container(
            padding: EdgeInsets.all(AppStyle.pL),
            decoration: BoxDecoration(
              borderRadius: AppStyle.rXL,
              boxShadow: AppStyle.stealthShadow,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppStyle.mainCardGradient,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AVAILABLE FUNDS', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  '\$${balance.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white, fontSize: AppStyle.fXXL, fontWeight: FontWeight.bold, letterSpacing: -1),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildCompactStat('INCOME', '+\$${totalIncome.toStringAsFixed(0)}', AppStyle.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCompactStat('EXPENSES', '-\$${totalExpense.toStringAsFixed(0)}', AppStyle.accentRed)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildCompactStat('SAVED', '\$${saved.toStringAsFixed(0)}', Colors.yellowAccent)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Spending Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SPENDING', style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: AppStyle.fL, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Container(
                decoration: BoxDecoration(color: AppStyle.getSurface(context), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    _buildMiniTab('W', _selectedFilter == 'W'),
                    _buildMiniTab('M', _selectedFilter == 'M'),
                    _buildMiniTab('Y', _selectedFilter == 'Y'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // REAL SPENDING CHART
          LayoutBuilder(
            builder: (context, constraints) {
              final double chartContentWidth = constraints.maxWidth - (AppStyle.pL * 2);
              final double barWidth = chartData.isEmpty ? 28 : (chartContentWidth / chartData.length).clamp(8.0, 28.0);
              const double barSpacing = 4.0;
              
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: AppStyle.getSurface(context).withValues(alpha: 0.5), borderRadius: AppStyle.rL),
                child: Padding(
                  padding: EdgeInsets.all(AppStyle.pL),
                  child: chartData.isEmpty
                    ? Center(child: Text('No spending data', style: TextStyle(color: AppStyle.getSubtitle(context))))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((data) {
                          return _buildChartBar(
                            (data['amount'] as double) / displayMax,
                            data['day'] as String,
                            width: barWidth - barSpacing,
                          );
                        }).toList(),
                      ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'REPORTS & TRANSACTIONS', 
                  style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: AppStyle.fL, fontWeight: FontWeight.bold, letterSpacing: 1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: AppStyle.primary, fontSize: AppStyle.fS, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Transaction List
          transactions.isEmpty 
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, color: Colors.grey, size: 48.r),
                      const SizedBox(height: 12),
                      const Text('No transactions yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length > 10 ? 10 : transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sortedList = [...transactions];
                  sortedList.sort((a, b) => b.date.compareTo(a.date));
                  return TransactionListTile(transaction: sortedList[index]);
                },
              ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  List<Map<String, dynamic>> _getChartData(List<dynamic> transactions) {
    final now = DateTime.now();

    if (_selectedFilter == 'W') {
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        final total = transactions
            .where((t) =>
                t.type == TransactionType.expense &&
                t.date.year == date.year &&
                t.date.month == date.month &&
                t.date.day == date.day)
            .fold(0.0, (sum, t) => sum + t.amount);
        return {'day': _getDayName(date.weekday), 'amount': total};
      });
    } else if (_selectedFilter == 'M') {
      return List.generate(4, (index) {
        final weekEnd = now.subtract(Duration(days: (3 - index) * 7));
        final weekStart = weekEnd.subtract(const Duration(days: 6));
        final total = transactions
            .where((t) =>
                t.type == TransactionType.expense &&
                !t.date.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
                !t.date.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59)))
            .fold(0.0, (sum, t) => sum + t.amount);
        return {'day': 'W${index + 1}', 'amount': total};
      });
    } else {
      return List.generate(12, (index) {
        final month = DateTime(now.year, now.month - 11 + index);
        final total = transactions
            .where((t) =>
                t.type == TransactionType.expense &&
                t.date.year == month.year &&
                t.date.month == month.month)
            .fold(0.0, (sum, t) => sum + t.amount);
        return {'day': _getMonthName(month.month), 'amount': total};
      });
    }
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: AppStyle.fXXS, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(width: 2, height: 12, color: color),
            const SizedBox(width: 6),
            Text(value, style: TextStyle(color: Colors.white, fontSize: AppStyle.fS, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniTab(String label, bool active) {
    return BouncingWrapper(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: active ? AppStyle.primary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(color: active ? Colors.black : AppStyle.getSubtitle(context), fontSize: AppStyle.fXS, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildChartBar(double progress, String day, {double width = 30}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: width,
          height: (140 * progress).clamp(4.0, 140.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppStyle.secondary.withValues(alpha: progress > 0 ? 0.8 : 0.05),
                AppStyle.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(width / 5),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: width < 20 ? 7 : 9, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
