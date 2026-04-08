import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../core/app_style.dart';

class CategorySpendingScreen extends ConsumerWidget {
  const CategorySpendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();
    
    // Dynamic Category Aggregation
    final Map<String, double> catTotals = {};
    double totalExpense = 0;
    for (var t in expenseTransactions) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    final List<PieChartSectionData> sections = catTotals.entries.map((e) {
      final index = catTotals.keys.toList().indexOf(e.key);
      final color = _getCategoryColor(index);
      return PieChartSectionData(
        value: e.value,
        title: e.key.substring(0, 1).toUpperCase(),
        color: color,
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppStyle.pL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('CATEGORY WISE', style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 1)),
          Text('SPENDING', style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 32, fontWeight: FontWeight.bold, height: 0.9)),
          const SizedBox(height: 48),

          // THE PIE CHART
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 50,
                sectionsSpace: 4,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          Text('BREAKDOWN', style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),

          if (catTotals.isEmpty)
            Center(child: Text('No categorized spending', style: TextStyle(color: AppStyle.getSubtitle(context))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: catTotals.length,
              itemBuilder: (context, i) {
                final entry = catTotals.entries.toList()[i];
                final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);
                return _buildCategoryItem(context, entry.key, entry.value, percentage, _getCategoryColor(i));
              },
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [AppStyle.primary, AppStyle.secondary, Colors.amber, Colors.cyan, Colors.deepOrange, Colors.pink, Colors.lightGreen];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':       return Icons.restaurant;
      case 'transport':  return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'shopping':   return Icons.shopping_bag;
      case 'health':     return Icons.favorite;
      case 'bills':      return Icons.receipt_long;
      case 'income':     return Icons.trending_up;
      default:           return Icons.category;
    }
  }

  Widget _buildCategoryItem(BuildContext context, String title, double amount, String percentage, Color color) {
    final icon = _getCategoryIcon(title);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(AppStyle.pM),
      decoration: BoxDecoration(color: AppStyle.getSurface(context), borderRadius: AppStyle.rM),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$percentage % of total', style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 11)),
            ]),
          ),
          Text('\$${amount.toStringAsFixed(0)}', style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.w300, fontSize: 18)),
        ],
      ),
    );
  }
}
