import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../core/app_style.dart';
import 'package:intl/intl.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.type == TransactionType.income;
    
    return Container(
      padding: EdgeInsets.all(AppStyle.pM),
      decoration: BoxDecoration(
        color: AppStyle.getSurface(context),
        borderRadius: AppStyle.rM,
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isIncome ? AppStyle.primary : AppStyle.accentRed).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _getTransactionIcon(t.category),
              color: isIncome ? AppStyle.primary : AppStyle.accentRed,
              size: 20,
            ),
          ),
          SizedBox(width: AppStyle.pM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title.isEmpty ? t.category : t.title,
                  style: TextStyle(
                    color: AppStyle.getOnSurface(context),
                    fontWeight: FontWeight.bold,
                    fontSize: AppStyle.fS,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('d MMM').format(t.date)} • ${t.category}',
                  style: TextStyle(
                    color: AppStyle.getSubtitle(context),
                    fontSize: AppStyle.fXXS + 2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isIncome ? AppStyle.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppStyle.fM,
                ),
              ),
              if (t.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.notes, size: 12, color: AppStyle.getSubtitle(context)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_car;
      case 'entertainment': return Icons.movie;
      case 'shopping': return Icons.shopping_bag;
      case 'health': return Icons.favorite;
      case 'bills': return Icons.receipt_long;
      case 'income': return Icons.add_chart;
      case 'salary': return Icons.payments;
      case 'investment': return Icons.trending_up;
      default: return Icons.category;
    }
  }
}
