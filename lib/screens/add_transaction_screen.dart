import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/scanner_provider.dart';
import '../widgets/bouncing_wrapper.dart';
import '../core/app_style.dart';
import 'package:image_picker/image_picker.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String _category = 'Food';
  DateTime _date = DateTime.now();

  final List<String> _categories = ['Food', 'Transport', 'Entertainment', 'Shopping', 'Health', 'Bills', 'Other'];
  bool _isScanning = false;

  void _scanReceipt(ImageSource source) async {
    try {
      setState(() => _isScanning = true);
      final scanner = ref.read(scannerServiceProvider);
      final data = await scanner.scanReceipt(source);
      setState(() => _isScanning = false);
      
      if (data != null) {
        if (data.amount == null && data.merchant == null && data.category == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gemini could not read this receipt. Check your internet connection and try again.'),
              backgroundColor: AppStyle.accentRed,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          setState(() {
            if (data.amount != null) _amountController.text = data.amount!.toStringAsFixed(2);
            if (data.merchant != null) _titleController.text = data.merchant!;
            if (data.category != null && _categories.contains(data.category)) {
              _category = data.category!;
              _type = TransactionType.expense; // Switch to expense mode if category detected
            }
          });
          final fields = [
            if (data.merchant != null) 'Title',
            if (data.amount != null) 'Amount',
            if (data.category != null) 'Category',
          ];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: ${fields.join(', ')} detected!'),
              backgroundColor: AppStyle.accentGreen,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Scanning Cancelled'), backgroundColor: AppStyle.getSurface(context)),
        );
      }
    } catch (e) {
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning receipt: $e'), backgroundColor: AppStyle.accentRed),
      );
    }
  }

  void _showScannerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppStyle.getSurface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SCAN RECEIPT', style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppStyle.primary),
              title: Text('TAKE PHOTO', style: TextStyle(color: AppStyle.getOnSurface(context))),
              onTap: () { Navigator.pop(context); _scanReceipt(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppStyle.secondary),
              title: Text('CHOOSE FROM GALLERY', style: TextStyle(color: AppStyle.getOnSurface(context))),
              onTap: () { Navigator.pop(context); _scanReceipt(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter TITLE and AMOUNT'), backgroundColor: AppStyle.accentRed),
      );
      return;
    }

    final tx = TransactionModel(
      title: _titleController.text,
      amount: amount,
      date: _date,
      category: _type == TransactionType.expense ? _category : 'Income',
      type: _type,
      note: _noteController.text,
    );

    ref.read(transactionProvider.notifier).addTransaction(tx);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.getBg(context),
      appBar: AppBar(
        title: Text('ADD TRANSACTION', style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppStyle.pL),
            child: Column(
              children: [
                const SizedBox(height: 24),
                
                // Neon Type Switcher
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: AppStyle.getSurface(context), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildTypeBtn('EXPENSE', TransactionType.expense),
                      _buildTypeBtn('INCOME', TransactionType.income),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Amount Input (Large)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('\$ ', style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 48, fontWeight: FontWeight.bold)),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 48, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppStyle.getSubtitle(context).withValues(alpha: 0.1)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Form Content
                _buildFieldCard(
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(color: AppStyle.getOnSurface(context)),
                    decoration: InputDecoration(
                      hintText: 'TITLE / MERCHANT',
                      hintStyle: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 12),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: AppStyle.secondary),
                        onPressed: _showScannerOptions,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_type == TransactionType.expense) ...[
                  Align(alignment: Alignment.centerLeft, child: Text('CATEGORY', style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 10, letterSpacing: 1))),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _category == cat;
                        return BouncingWrapper(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppStyle.secondary : AppStyle.getSurface(context),
                              borderRadius: AppStyle.rM,
                            ),
                            child: Center(
                              child: Text(
                                cat.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppStyle.getSubtitle(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                _buildFieldCard(
                  child: ListTile(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: _date, 
                        firstDate: DateTime(2000), 
                        lastDate: DateTime(2100),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppStyle.secondary),
                          ),
                          child: child!,
                        ),
                      );
                      if (d != null) setState(() => _date = d);
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_today, color: AppStyle.getSubtitle(context), size: 20),
                    title: Text(DateFormat('MMMM dd, yyyy').format(_date), style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 14)),
                    trailing: Icon(Icons.chevron_right, color: AppStyle.getSubtitle(context)),
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldCard(
                  child: TextField(
                    controller: _noteController,
                    maxLines: 2,
                    style: TextStyle(color: AppStyle.getOnSurface(context)),
                    decoration: InputDecoration(
                      hintText: 'ADD NOTE (OPTIONAL)',
                      hintStyle: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Save Button
                BouncingWrapper(
                  onTap: _save,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppStyle.mainCardGradient),
                      borderRadius: AppStyle.rL,
                      boxShadow: AppStyle.stealthShadow,
                    ),
                    child: Center(
                      child: Text(
                        'SAVE TRANSACTION',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 2
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppStyle.primary),
                    SizedBox(height: 20),
                    Text('GEMINI AI READING RECEIPT...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
                    SizedBox(height: 8),
                    Text('This may take a few seconds', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeBtn(String label, TransactionType type) {
    final isSelected = _type == type;
    return Expanded(
      child: BouncingWrapper(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? AppStyle.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: AppStyle.secondary.withValues(alpha: 0.3), blurRadius: 10)] : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppStyle.getSubtitle(context),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppStyle.getSurface(context), borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}
