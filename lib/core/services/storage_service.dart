import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Unified Service to manage all app data
class StorageService {
  static const String _transactionsBoxName = 'transactions_box';
  static const String _savingsBoxName = 'savings_box';
  static const String _settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_transactionsBoxName);
    await Hive.openBox(_savingsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  Box get transactionsBox => Hive.box(_transactionsBoxName);
  Box get savingsBox => Hive.box(_savingsBoxName);
  Box get settingsBox => Hive.box(_settingsBoxName);

  // Generic Get/Set for future-proofing
  T? getData<T>(String boxName, String key, {T? defaultValue}) {
    return Hive.box(boxName).get(key, defaultValue: defaultValue);
  }

  Future<void> setData(String boxName, String key, dynamic value) async {
    await Hive.box(boxName).put(key, value);
  }
}

// Global Provider for the Storage Service
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
