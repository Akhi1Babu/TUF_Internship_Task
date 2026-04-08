import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final Color color;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.color,
  });

  SavingsGoal copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    Color? color,
  }) {
    return SavingsGoal(
      id: this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      color: color ?? this.color,
    );
  }

  factory SavingsGoal.fromJson(Map<dynamic, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      title: json['title'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      color: Color(json['colorValue']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'colorValue': color.value,
    };
  }
}
