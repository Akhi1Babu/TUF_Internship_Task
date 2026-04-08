import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../core/services/storage_service.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    final storage = ref.watch(storageServiceProvider);
    final data = storage.transactionsBox.get('transactions', defaultValue: []);
    final List<TransactionModel> items = (data as List).map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state]..sort((a, b) => b.date.compareTo(a.date));
    _saveToHive();
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveToHive();
  }

  void _saveToHive() {
    final storage = ref.read(storageServiceProvider);
    final List<Map<String, dynamic>> rawData = state.map((t) => t.toJson()).toList();
    storage.transactionsBox.put('transactions', rawData);
  }
}

final transactionProvider = NotifierProvider<TransactionNotifier, List<TransactionModel>>(TransactionNotifier.new);

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
