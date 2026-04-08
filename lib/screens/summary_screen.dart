import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';
import '../widgets/bouncing_wrapper.dart';
import '../core/app_style.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool isMonthly = true;

  void _showBudgetSheet({
    required String title,
    required double initialValue,
    required Function(double) onSave,
  }) {
    double tempValue = initialValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppStyle.getSurface(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border.all(color: Colors.white10),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppStyle.pL, 16.h, AppStyle.pL, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppStyle.getSubtitle(context),
                      fontSize: AppStyle.fXS,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          color: AppStyle.primary.withValues(alpha: 0.5),
                          fontSize: AppStyle.fM,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                      ),
                      Text(
                        '${tempValue.toInt()}',
                        style: TextStyle(
                          color: AppStyle.getOnSurface(context),
                          fontSize: 44.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppStyle.primary,
                      inactiveTrackColor: Colors.white10,
                      thumbColor: Colors.white,
                      overlayColor: AppStyle.primary.withValues(alpha: 0.2),
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 8.r,
                        elevation: 3,
                      ),
                    ),
                    child: Slider(
                      value: tempValue.clamp(0, 20000),
                      min: 0,
                      max: 20000,
                      divisions: 200,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setSheetState(
                          () => tempValue = (val / 50).round() * 50.0,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [50, 100, 500]
                        .map(
                          (increment) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: BouncingWrapper(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setSheetState(
                                  () => tempValue = (tempValue + increment)
                                      .clamp(0, 20000),
                                );
                              },
                              child: Builder(
                                builder: (context) {
                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark 
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isDark ? Colors.white10 : Colors.black12,
                                      ),
                                    ),
                                    child: Text(
                                      '+\$$increment',
                                      style: TextStyle(
                                        color: AppStyle.getOnSurface(context).withValues(alpha: 0.7),
                                        fontSize: AppStyle.fXXS + 2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  SizedBox(height: 24.h),

                  BouncingWrapper(
                    onTap: () {
                      onSave(tempValue);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: AppStyle.primary,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppStyle.primary.withValues(alpha: 0.2),
                            blurRadius: 15.r,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'CONFIRM',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: AppStyle.fS,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(double currentBudget) {
    _showBudgetSheet(
      title: 'MONTHLY BUDGET',
      initialValue: currentBudget,
      onSave: (val) => ref.read(budgetProvider.notifier).setGlobalBudget(val),
    );
  }

  void _showCategoryDialog(String category, double currentBudget) {
    _showBudgetSheet(
      title: '${category.toUpperCase()} BUDGET',
      initialValue: currentBudget,
      onSave: (val) =>
          ref.read(budgetProvider.notifier).setCategoryBudget(category, val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final budgetState = ref.watch(budgetProvider);
    final monthlyBudget = budgetState.globalBudget;
    final catBudgets = budgetState.categoryBudgets;

    final double usedPercentage = (totalExpense / monthlyBudget).clamp(
      0.0,
      1.0,
    );
    final double left = (monthlyBudget - totalExpense).clamp(
      0.0,
      monthlyBudget,
    );

    final Map<String, double> catTotals = {};
    for (var t in transactions.where(
      (tx) => tx.type == TransactionType.expense,
    )) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppStyle.pL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          Text(
            'TOTAL MONTHLY',
            style: TextStyle(
              color: AppStyle.getSubtitle(context),
              fontSize: 32.sp,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUDGET',
                style: TextStyle(
                  color: AppStyle.getOnSurface(context),
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                ),
              ),
              BouncingWrapper(
                onTap: () => _showBudgetDialog(monthlyBudget),
                child: Builder(
                  builder: (context) {
                    final accentColor =
                        Theme.of(context).brightness == Brightness.dark
                        ? AppStyle.primary
                        : AppStyle.secondary;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: accentColor,
                            size: 14.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'SET LIMIT',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: AppStyle.fXS,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          Container(
            padding: EdgeInsets.all(AppStyle.pL),
            decoration: BoxDecoration(
              borderRadius: AppStyle.rXL,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppStyle.mainCardGradient,
              ),
              boxShadow: AppStyle.stealthShadow,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(usedPercentage * 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 84.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, left: 4.w),
                      child: Text(
                        '%',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: AppStyle.fXL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'USED THIS MONTH',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: AppStyle.fXS,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 32.h),

                Stack(
                  children: [
                    Container(
                      height: 8.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: usedPercentage,
                      child: Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppStyle.primary,
                          borderRadius: BorderRadius.circular(4.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppStyle.primary.withValues(alpha: 0.5),
                              blurRadius: 10.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                      'SPENT',
                      '\$${totalExpense.toStringAsFixed(0)}',
                      AppStyle.accentRed,
                    ),
                    _buildStat(
                      'BUDGET',
                      '\$${monthlyBudget.toStringAsFixed(0)}',
                      Colors.white38,
                    ),
                    _buildStat(
                      'LEFT',
                      '\$${left.toStringAsFixed(0)}',
                      AppStyle.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 48.h),
          Text(
            'CATEGORIES',
            style: TextStyle(
              color: AppStyle.getOnSurface(context),
              fontSize: AppStyle.fL,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 24.h),

          ...[
            'Food',
            'Transport',
            'Entertainment',
            'Shopping',
            'Health',
            'Bills',
            'Other',
          ].map((cat) {
            final spent = catTotals[cat] ?? 0.0;
            final categoryBudget = catBudgets[cat] ?? 1000.0;
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: BouncingWrapper(
                onTap: () => _showCategoryDialog(cat, categoryBudget),
                child: _buildCategoryTunnel(
                  context,
                  cat.toUpperCase(),
                  spent,
                  categoryBudget,
                  _getCategoryIcon(cat),
                  AppStyle.secondary,
                ),
              ),
            );
          }).toList(),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: AppStyle.fXXS,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: AppStyle.fM,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'shopping': return Icons.shopping_bag;
      case 'health': return Icons.favorite;
      case 'bills': return Icons.receipt_long;
      default: return Icons.category;
    }
  }

  Widget _buildCategoryTunnel(
    BuildContext context,
    String title,
    double spent,
    double budget,
    IconData icon,
    Color color,
  ) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppStyle.getSurface(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 18.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppStyle.getOnSurface(context),
                          fontSize: AppStyle.fS,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '\$${spent.toInt()}',
                        style: TextStyle(
                          color: AppStyle.getOnSurface(context),
                          fontSize: AppStyle.fS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Goal: \$${budget.toInt()}',
                        style: TextStyle(
                          color: AppStyle.getSubtitle(context),
                          fontSize: AppStyle.fXS,
                        ),
                      ),
                      Text(
                        '\$${(budget - spent).toInt()} remaining',
                        style: TextStyle(
                          color: (budget - spent) < 0
                              ? AppStyle.accentRed
                              : AppStyle.accentGreen,
                          fontSize: AppStyle.fXS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Stack(
          children: [
            Container(
              height: 6.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppStyle.getSubtitle(context).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: progress >= 1.0
                      ? AppStyle.accentRed
                      : AppStyle.primary,
                  borderRadius: BorderRadius.circular(3.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (progress >= 1.0
                                  ? AppStyle.accentRed
                                  : AppStyle.primary)
                              .withValues(alpha: 0.3),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
