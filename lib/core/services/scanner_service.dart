import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReceiptData {
  final double? amount;
  final String? merchant;
  final String? category;
  final DateTime? date;

  ReceiptData({this.amount, this.merchant, this.category, this.date});
}

class ScannerService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final ImagePicker _picker = ImagePicker();

  Future<ReceiptData?> scanReceipt(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (photo == null) return null;

      // Read image bytes
      final imageBytes = await File(photo.path).readAsBytes();

      // Send to Gemini Vision
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      const prompt = '''
You are a receipt scanner. Analyze this receipt image and extract:
1. The merchant/store name (usually at the top, the business name)
2. The total amount paid (look for "Total", "Grand Total", "Amount Due", "Payable" labels)
3. The best category from this list only: Food, Transport, Shopping, Entertainment, Health, Bills, Other

Respond in EXACTLY this format, nothing else:
MERCHANT: <store name or UNKNOWN>
AMOUNT: <number only, no currency symbols, e.g. 450.00 or UNKNOWN>
CATEGORY: <category from list or Other>
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await model.generateContent(content);
      final text = response.text ?? '';

      // Parse the structured response
      String? merchant;
      double? amount;
      String? category;

      for (final line in text.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('MERCHANT:')) {
          final val = trimmed.substring('MERCHANT:'.length).trim();
          if (val.toUpperCase() != 'UNKNOWN' && val.isNotEmpty) {
            merchant = val.toUpperCase();
          }
        } else if (trimmed.startsWith('AMOUNT:')) {
          final val = trimmed.substring('AMOUNT:'.length).trim();
          if (val.toUpperCase() != 'UNKNOWN') {
            amount = double.tryParse(val.replaceAll(',', ''));
          }
        } else if (trimmed.startsWith('CATEGORY:')) {
          final val = trimmed.substring('CATEGORY:'.length).trim();
          const validCats = [
            'Food',
            'Transport',
            'Shopping',
            'Entertainment',
            'Health',
            'Bills',
            'Other',
          ];
          if (validCats.any((c) => c.toLowerCase() == val.toLowerCase())) {
            category = validCats.firstWhere(
              (c) => c.toLowerCase() == val.toLowerCase(),
            );
          }
        }
      }

      return ReceiptData(
        amount: amount,
        merchant: merchant,
        category: category,
        date: DateTime.now(),
      );
    } catch (e) {
      print('SCANNER ERROR: $e');
      return ReceiptData(); // Return empty so UI handles gracefully
    }
  }

  void dispose() {}
}
