import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionCard extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isIncome = transaction.type == TransactionType.income;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(transactionProvider.notifier).removeTransaction(transaction.id);
      },
      child: Card(
        elevation: 0,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : [
               BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncome ? Icons.keyboard_double_arrow_up : Icons.fastfood_outlined,
                color: isIncome ? Colors.greenAccent : (isDark ? const Color(0xFFB5E4CA) : Colors.black),
              ),
            ),
            title: Text(
              transaction.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              '${transaction.category} \u2022 ${DateFormat.yMMMd().format(transaction.date)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? Colors.greenAccent : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

