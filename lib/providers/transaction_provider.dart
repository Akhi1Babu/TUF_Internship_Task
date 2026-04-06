import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      state = decoded.map((e) => TransactionModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> _saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(transactions.map((e) => e.toJson()).toList());
    prefs.setString('transactions', encoded);
  }

  void addTransaction(TransactionModel transaction) {
    final newState = [...state, transaction]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = newState;
    _saveTransactions(newState);
  }

  void removeTransaction(String id) {
    final newState = state.where((t) => t.id != id).toList();
    state = newState;
    _saveTransactions(newState);
  }
}

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});
