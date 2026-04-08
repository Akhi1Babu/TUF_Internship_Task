import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/storage_service.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    final bool isDark = storage.getData<bool>('settings_box', 'isDark', defaultValue: true) ?? true;

    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    final storage = ref.read(storageServiceProvider);
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await storage.setData('settings_box', 'isDark', true);
    } else {
      state = ThemeMode.light;
      await storage.setData('settings_box', 'isDark', false);
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
