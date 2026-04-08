import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String note;
  final TransactionType type;
  final String? goalId; // Links transaction to a savings goal

  TransactionModel({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
    required this.type,
    this.goalId,
  }) : id = id ?? const Uuid().v4();

  factory TransactionModel.fromJson(Map<dynamic, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      note: json['note'] ?? '',
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      goalId: json['goalId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'note': note,
      'type': type.name,
      'goalId': goalId,
    };
  }
}
