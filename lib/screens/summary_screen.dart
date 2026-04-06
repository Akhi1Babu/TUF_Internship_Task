import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final expenseTxs = transactions.where((t) => t.type == TransactionType.expense).toList();
    
    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var t in expenseTxs) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final List<PieChartSectionData> sections = _generateSections(categoryTotals);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (categoryTotals.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No expense data available for summary', style: TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 50,
                    sectionsSpace: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: categoryTotals.keys.length,
                  itemBuilder: (context, index) {
                    final category = categoryTotals.keys.elementAt(index);
                    final amount = categoryTotals[category]!;
                    return ListTile(
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getColor(category),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(category),
                      trailing: Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> totals) {
    if (totals.isEmpty) return [];
    final totalExpense = totals.values.reduce((a, b) => a + b);
    return totals.entries.map((entry) {
      final percentage = (entry.value / totalExpense) * 100;
      return PieChartSectionData(
        color: _getColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Utilities': return Colors.purple;
      case 'Entertainment': return Colors.pink;
      case 'Salary': return Colors.green;
      default: return Colors.grey;
    }
  }
}
