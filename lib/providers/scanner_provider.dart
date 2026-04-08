import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/scanner_service.dart';

final scannerServiceProvider = Provider.autoDispose<ScannerService>((ref) {
  final service = ScannerService();
  ref.onDispose(() => service.dispose());
  return service;
});
