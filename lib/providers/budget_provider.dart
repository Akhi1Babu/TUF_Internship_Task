import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

class CategoryBudgetState {
  final double globalBudget;
  final Map<String, double> categoryBudgets;

  CategoryBudgetState({required this.globalBudget, required this.categoryBudgets});

  CategoryBudgetState copyWith({double? globalBudget, Map<String, double>? categoryBudgets}) {
    return CategoryBudgetState(
      globalBudget: globalBudget ?? this.globalBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }
}

class BudgetNotifier extends Notifier<CategoryBudgetState> {
  @override
  CategoryBudgetState build() {
    final storage = ref.watch(storageServiceProvider);
    
    final global = storage.getData<double>('settings_box', 'monthly_budget', defaultValue: 3000.0) ?? 3000.0;
    final catBudgetsRaw = storage.getData<Map<dynamic, dynamic>>('settings_box', 'category_budgets', defaultValue: {}) ?? {};
    
    final Map<String, double> catBudgets = {};
    catBudgetsRaw.forEach((k, v) => catBudgets[k.toString()] = (v as num).toDouble());

    return CategoryBudgetState(globalBudget: global, categoryBudgets: catBudgets);
  }

  Future<void> setGlobalBudget(double amount) async {
    state = state.copyWith(globalBudget: amount);
    final storage = ref.read(storageServiceProvider);
    await storage.setData('settings_box', 'monthly_budget', amount);
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    final newCatBudgets = Map<String, double>.from(state.categoryBudgets);
    newCatBudgets[category] = amount;
    state = state.copyWith(categoryBudgets: newCatBudgets);
    
    final storage = ref.read(storageServiceProvider);
    await storage.setData('settings_box', 'category_budgets', newCatBudgets);
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, CategoryBudgetState>(BudgetNotifier.new);
