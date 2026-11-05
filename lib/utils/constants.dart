import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String currencySymbol = '৳';

const String typeIncome = 'Income';
const String typeExpense = 'Expense';

const List<String> categories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Entertainment',
  'Education',
  'Salary',
  'Business',
  'Gift',
  'Other',
];

final DateFormat dateFormatter = DateFormat('dd MMM yyyy');

String formatMoney(double value) => '$currencySymbol${value.toStringAsFixed(2)}';

Color typeColor(String type) =>
    type == typeIncome ? Colors.green.shade700 : Colors.red.shade700;

/// Shows a confirmation AlertDialog. Returns true if user confirms.
Future<bool> confirmDelete(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Transaction'),
      content: Text('Are you sure you want to delete "$title"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
