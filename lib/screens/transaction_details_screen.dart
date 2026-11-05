import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionModel _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: _transaction),
      ),
    );
    // Reload the latest saved data from the database.
    final updated =
        await DatabaseHelper.instance.getTransactionById(_transaction.id!);
    if (!mounted) return;
    if (updated != null) setState(() => _transaction = updated);
  }

  Future<void> _delete() async {
    final ok = await confirmDelete(context, _transaction.title);
    if (!ok) return;
    await DatabaseHelper.instance.deleteTransaction(_transaction.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
    Navigator.pop(context, true);
  }

  Widget _row(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 14),
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaction;
    final isIncome = t.type == typeIncome;
    final color = typeColor(t.type);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          isIncome ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${isIncome ? '+' : '-'}${formatMoney(t.amount)}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(t.title, style: const TextStyle(fontSize: 18)),
                    const Divider(height: 32),
                    _row(Icons.title, 'Title', t.title),
                    _row(Icons.attach_money, 'Amount', formatMoney(t.amount)),
                    _row(Icons.category, 'Category', t.category),
                    _row(Icons.swap_vert, 'Type', t.type, color: color),
                    _row(Icons.calendar_today, 'Date',
                        dateFormatter.format(t.date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _delete,
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
