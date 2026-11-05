import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == typeIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == typeExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    _loadTransactions();
  }

  Future<void> _openDetails(TransactionModel t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: t)),
    );
    _loadTransactions();
  }

  Future<void> _openAll() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionListScreen()),
    );
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final recent = _transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SummaryCard(
                          title: 'Current Balance',
                          value: formatMoney(_balance),
                          icon: Icons.account_balance_wallet,
                          color: _balance >= 0
                              ? Colors.indigo
                              : Colors.red.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Total Income',
                              value: formatMoney(_totalIncome),
                              icon: Icons.trending_up,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Expanded(
                            child: SummaryCard(
                              title: 'Total Expense',
                              value: formatMoney(_totalExpense),
                              icon: Icons.trending_down,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _openAll,
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: recent.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions yet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: recent.length,
                          itemBuilder: (context, index) {
                            final t = recent[index];
                            return TransactionTile(
                              transaction: t,
                              onTap: () => _openDetails(t),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
