import 'package:flutter/material.dart';
import '../widgets/expense_screen/expense_fetcher.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({Key? key}) : super(key: key);
  static const name = '/expense_screen';

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;
    print(category);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Screen')),
      body: ExpenseFetcher(category: category),
    );
  }
}
