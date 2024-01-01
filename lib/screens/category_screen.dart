import 'package:expenseapp/widgets/expense_form.dart';
import 'package:flutter/material.dart';

import '../widgets/category_screen/category_fetcher.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);
  static const name = '/category_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body:  const CategoryFetcher(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ExpenseForm());
        },
      ),
    );
  }
}
