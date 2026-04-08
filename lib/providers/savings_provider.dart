import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings_goal.dart';

class SavingsNotifier extends Notifier<List<SavingsGoal>> {
  late Box _box;

  @override
  List<SavingsGoal> build() {
    _box = Hive.box('savings_box');
    _loadFromHive();
    return [];
  }

  void _loadFromHive() {
    final data = _box.get('savings_list', defaultValue: []);
    state = (data as List).map((e) => SavingsGoal.fromJson(Map<String, dynamic>.from(e))).toList();
    
    // Add defaults if empty for a great first-run experience
    if (state.isEmpty) {
      state = [
        SavingsGoal(id: '1', title: 'New Laptop', targetAmount: 1200, currentAmount: 0, color: const Color(0xFFB5E4CA)),
        SavingsGoal(id: '2', title: 'Emergency Fund', targetAmount: 5000, currentAmount: 0, color: const Color(0xFFEABC96)),
      ];
      _saveToHive();
    }
  }

  void _saveToHive() {
    final rawData = state.map((g) => g.toJson()).toList();
    _box.put('savings_list', rawData);
  }

  void addGoal(String title, double target, Color color) {
    state = [...state, SavingsGoal(
      id: DateTime.now().toIso8601String(),
      title: title,
      targetAmount: target,
      currentAmount: 0,
      color: color,
    )];
    _saveToHive();
  }

  void updateCurrentAmount(String id, double amount) {
    state = [
      for (final goal in state)
        if (goal.id == id) goal.copyWith(currentAmount: amount) else goal,
    ];
    _saveToHive();
  }

  void deleteGoal(String id) {
    state = state.where((g) => g.id != id).toList();
    _saveToHive();
  }
}

final savingsProvider = NotifierProvider<SavingsNotifier, List<SavingsGoal>>(SavingsNotifier.new);
