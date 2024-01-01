import 'package:flutter/material.dart';

import '../widgets/all_expense_screen/all_expenses_fetcher.dart';

class AllExpenses extends StatefulWidget {
  const AllExpenses({Key? key}) : super(key: key);
  static const name = '/all_expenses';

  @override
  State<AllExpenses> createState() => _AllExpensesState();
}

class _AllExpensesState extends State<AllExpenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses'),),
      body: AllExpensesFetcher(),
    );
  }
}


